module tb;
  
bit CLK_50MHZ = 0;
logic CLK_1MHZ;
bit rst = 1;
bit sdo = 0;
logic [5:0] mode;
logic [11:0] adc;
  
//variaveis de teste
logic [11:0] adc_reading;
logic [11:0] adc_buffer;
logic [5:0] mode_bff = 0;
logic [5:0] cont_mode = 0;
  
wire convst, sck, sdi;
wire [11:0] out;
int times;
  
clock_div cd(.clk(CLK_50MHZ), .reset(rst), .fator(26'd25), .new_clk(CLK_1MHZ));
  
controle_adc ca(CLK_1MHZ, sck, convst, sdo, sdi, out, mode, rst); 
  
  initial   
    begin    
      mode = $urandom();
      
//Reset

	rst = 0;
	#1000
	rst = 1;
	#1
      
    //Teste de funcionamento do reset  
	/*
    rst = 0;
	#1000
	rst = 1;
	#1000
	rst = 0;
	#1000
	rst = 1;
	#1
     */
      
	@(posedge convst)
	times = $time;
	@(negedge convst)
	$display("tempo de conversão = %d ms", ($time - times) * 10);
	times = $time;
	@(posedge convst)
	$display("tempo de envio de dados e impressão = %d ms", ($time - times) * 10);
        
	repeat(10)
		begin
			adc_reading = $urandom();
            adc_buffer = adc_reading;
          repeat(12)
            begin
              @(posedge sck)
              sdo = adc_buffer & 1;
              adc_buffer = adc_buffer >> 1;
            end
          @(posedge convst)
          if(out != adc_reading)
            begin
              $display("erro no recepcinamento de dados do driver");
              $finish;
            end
        end

	repeat(10)
        begin

          mode = $urandom();
          @(posedge convst)
          repeat(6)
            begin
              @(posedge sck)
              if(cont_mode < 6)
                begin
                  mode_bff = mode_bff >> 1;			           
                  mode_bff = (sdi << 5) + mode_bff;
                  cont_mode++;
                end
            end	
          @(posedge convst)
          if(mode != mode_bff)
            begin
              $display("erro na configuracao do adc");
              $finish;
            end
          cont_mode = 0;
        end

          $display("Successful");
          $finish;
        end
  
  always @(posedge convst)
    if(!rst)
      begin
        $display("Erro, reset não funciona");
        $finish;
      end

  always #10 CLK_50MHZ = ~CLK_50MHZ;

  initial
    begin
      $dumpfile("tb.vcd");
      $dumpvars(0);
    end
  initial #9000000 $finish;
  
endmodule