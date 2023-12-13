// Divisor de frenquencia

module clock_div( input clk, input reset, input logic [25:0] fator, output logic new_clk );
         
    reg [25:0] count;
   
  always @ (posedge clk or negedge reset)
    begin
      if (!reset) begin
         count <= 0;
           new_clk <= 0;
      end
      else
        if (count == (fator - 1)) begin
          	count <= 0;
             new_clk <= ~new_clk;
         end
         else begin
            count <= count + 1;
            new_clk <= new_clk;
         end
    end
endmodule

module controle_adc (clk, adc_sck, adc_convst, adc_sdo, adc_sdi, dataout, conf, reset);
  
  // Declarações de entradas e saídas
  input clk, reset, adc_sdo;
  input [5:0] conf;
  output bit adc_sck, adc_sdi, adc_convst;
  output logic [11:0] dataout;
  
  // Enumeração para os estados do FSM
  enum logic [2:0] {reset_s, converter, receber, esperar,imprimir} estado = reset_s;
  
  // Contadores e variáveis de controle
  int cont = 0;
  int cont_conf = 0;
  logic [5:0] conf_int = 0;
  logic [11:0] buffer = 0;
  logic [11:0] prev_out = 0;
  
  // FSM para controle de estados
  always @(posedge clk or negedge reset)
    begin
      if(!reset)						// reseta o driver
        begin
          cont = 0;
          estado <= reset_s;
          conf_int = 0;
          cont_conf = 0;
        end
      else
        if(cont < 2)				// 2 us para estabilizar o adc
          begin
            estado <= reset_s;
            conf_int <= conf;
            cont_conf = 0;
          end
      else
        if(cont < 4)				// 2 us para converter
          begin
            estado <= converter;
            conf_int <= conf;
            cont_conf = 0;
            
          end
      else
        if(cont < 5)				// 2 us para converter
          begin
            estado <= esperar;
          end
      else
        if(cont < 16)				// 12 us para receber os dados
          begin  
            estado <= receber;
            cont_conf++;
          end
      else
        if(cont < 18)				// 2 us para imprimir
          begin  
           estado <= imprimir;
           cont_conf = 0;
           conf_int <= conf;
          end
      else
        begin
          estado <= reset_s;
          conf_int = 0;
          cont_conf = 0;
          cont = 0;
        end
      cont++;
    end
  
  // Lógica combinacional para determinar saídas
  always_comb
  begin
    // Atribuições padrões para os sinais
    adc_convst = 0;
    adc_sck = 0;
    dataout = prev_out;

    case (estado)
      reset_s: begin
        // Nenhuma atribuição adicional necessária aqui, já que valores padrões são aplicados
      end
      converter: begin
        adc_convst = 1;  // habilita a conversão
      end
      receber: begin
        adc_sck = clk;  // começa a receber os dados
      end
      esperar: begin
        // Nenhuma atribuição adicional necessária aqui
      end
      imprimir: begin
        dataout = buffer;  // imprime o buffer
      end
    endcase
  end
  

  // Atualização de saída quando ocorre transição de clock_int
  always @(posedge clk or negedge reset)
    begin
      if(!reset)
        prev_out <= 0; 
      else
        prev_out <= dataout; 
    end

  // FPGA envia a configuração
  always @(posedge adc_sck)
    begin
      if(cont_conf < 6)
        adc_sdi <= conf_int[cont_conf];
      else
        adc_sdi <= 0;
    end
  
  
// Declaração de variáveis
reg [11:0] contador;
reg [11:0] buffer_temp;


always_ff @(negedge adc_sck) begin	
  if (estado == receber) begin
    // Incrementa o contador a cada borda de descida de adc_sck
		contador <= 0;
    // Lógica para armazenar os dados no buffer_temp
    case (contador)
      0  : buffer_temp[11] <= adc_sdo;
      1  : buffer_temp[10] <= adc_sdo;
      2  : buffer_temp[9]  <= adc_sdo;
      3  : buffer_temp[8]  <= adc_sdo;
      4  : buffer_temp[7]  <= adc_sdo;
      5  : buffer_temp[6]  <= adc_sdo;
      6  : buffer_temp[5]  <= adc_sdo;
      7  : buffer_temp[4]  <= adc_sdo;
      8  : buffer_temp[3]  <= adc_sdo;
      9  : buffer_temp[2]  <= adc_sdo;
      10 : buffer_temp[1]  <= adc_sdo;
      11 : buffer_temp[0]  <= adc_sdo;
    endcase
	 
	     contador <= contador + 1;

    // Se todos os bits foram recebidos, copia buffer_temp para buffer
    if (contador == 11) begin
      buffer <= buffer_temp;
      contador <= 0; // Reinicia o contador
    end
  end
end

 
endmodule

// Conversor Hexadecimal para Display de 7 Segmentos

module convHexa7Seg ( hexa, SeteSegmentos);
   input  [3:0] hexa;
    output [6:0] SeteSegmentos;
   
    always @ (hexa)
    begin
         case (hexa)
            4'b0000 : SeteSegmentos = 7'b1000000;
            4'b0001 : SeteSegmentos = 7'b1111001;
            4'b0010 : SeteSegmentos = 7'b0100100;
            4'b0011 : SeteSegmentos = 7'b0110000;
            4'b0100 : SeteSegmentos = 7'b0011001;
            4'b0101 : SeteSegmentos = 7'b0010010;
            4'b0110 : SeteSegmentos = 7'b0000010;
            4'b0111 : SeteSegmentos = 7'b1111000;
            4'b1000 : SeteSegmentos = 7'b0000000;
            4'b1001 : SeteSegmentos = 7'b0011000;      
            4'b1010 : SeteSegmentos = 7'b0001000;
            4'b1011 : SeteSegmentos = 7'b0000011;
            4'b1100 : SeteSegmentos = 7'b1000110;
            4'b1101 : SeteSegmentos = 7'b0100001;
            4'b1110 : SeteSegmentos = 7'b0000110;        
            4'b1111 : SeteSegmentos = 7'b0001110;                    
         endcase
   end
endmodule