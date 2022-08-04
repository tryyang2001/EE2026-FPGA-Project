`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2021 09:03:01 PM
// Design Name: 
// Module Name: Top_Student
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top_Student(
    input[15:0] sw, input btnC, btnL, btnR, btnU, btnD, input CLK, 
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,   // Connect to this signal from Audio_Capture.v
    output[15:0] led, output[3:0] an, output[6:0] seg, 
    output[7:0] JC
    );
//clock dividers
wire clk_2hz; calc_clk clk_2Hz (CLK, 24999999, clk_2hz);
wire clk_5hz; calc_clk clk_5Hz (CLK, 9999999, clk_5hz);
wire clk_25hz; calc_clk clk_25Hz (CLK, 1999999, clk_25hz);
wire clk_100hz; calc_clk clk_100Hz(CLK, 499999, clk_100hz); 
wire clk_381hz; calc_clk clk_381Hz(CLK, 131233, clk_381hz);
wire clk_20khz; calc_clk clk_20kHz(CLK, 2499, clk_20khz); 
wire clk_3p125Mhz; calc_clk clk_3p125MHz (CLK, 15, clk_3p125Mhz);
wire clk_6p25Mhz; calc_clk clk_6p25MHz(CLK, 7, clk_6p25Mhz);

//debouncing button pulse
wire pulse_left; my_sp_mod bpcL (clk_25hz, btnL, pulse_left);
wire pulse_right; my_sp_mod bpcR (clk_25hz, btnR, pulse_right);
wire pulse_centre; my_sp_mod bpcC (clk_25hz, btnC, pulse_centre);
wire pulse_up; my_sp_mod bpcU (clk_25hz, btnU, pulse_up);
wire pulse_down; my_sp_mod bpcD (clk_25hz, btnD, pulse_down);

//module instantiation for Audio Capture
wire[11:0] mic_in;
Audio_Capture ac(.CLK(CLK), .cs(clk_20khz), .MISO(J_MIC3_Pin3), .clk_samp(J_MIC3_Pin1), .sclk(J_MIC3_Pin4), .sample(mic_in));

//module instantiation for Oled Display
wire my_fb, send_pix, sample_pix, reset_sw;
wire[12:0] my_pix_index; 
reg[15:0] pix_data = 16'h0000;
wire[4:0] teststate;
assign reset_sw = sw[15];
Oled_Display(.clk(clk_6p25Mhz), .reset(reset_sw), .frame_begin(my_fb), .sending_pixels(send_pix),
  .sample_pixel(sample_pix), .pixel_index(my_pix_index), .pixel_data(pix_data), .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]),
  .pmoden(JC[7]), .teststate(teststate));
  
//module instantiation for xy-coordinate
wire[7:0] x, y;
xy_coordinates XY(my_pix_index, x, y);

//game 0 registers
reg[2:0] game = 0;
reg[7:0] ct_select = 64;
reg[3:0] an_game0 = 0;
reg[6:0] seg_game0 = 0;
reg[1:0] ct_an0 = 0; //each anode
reg[20:0] welcome = 0;
reg[15:0] led_game0 = 0;

//game 1 registers
reg[15:0] mainmenu[0:6143];
reg[15:0] INVERTED_mainmenu[0:6143];
reg[15:0] LOWCOLOUR;
reg[15:0] MEDCOLOUR;
reg[15:0] HIGHCOLOUR;
reg[15:0] BOARDER_COLOUR = 16'b11111_111111_11111;
reg[15:0] BACKGD_COLOUR = 0;
reg[7:0] lowerbound = 40;
reg[7:0] upperbound = 56;
reg[12:0] peak1 = 0;
reg[12:0] curr1 = 0;
reg[19:0] reset_peak_ct1 = 0;
reg[11:0] led_npeak = 0;
reg[15:0] led_peak = 0;
reg[5:0] volume1 = 0;
reg[2:0] ct_seg = 0;
reg[3:0] an_game1 = 4'b1111;
reg[6:0] seg_game1 = 0;

//game 2 registers
reg[15:0] ppincr[0:6143];
reg[15:0] mincr[0:6143];
reg[15:0] ppinw[0:6143];
reg[15:0] minw[0:6143];
reg[4:0] volume2 = 0;
reg [31:0] ct_an2 = 0;
reg[3:0] an_game2 = 4'b1111;
reg[6:0] seg_game2 = 0;
reg[15:0] led_peak2 = 0;
reg colourswitch = 0;
reg[31:0] mathsselect = 3600;
reg [31:0] reset_peak_ct2= 0;
reg [12:0] peak2 = 0;
reg [12:0] curr2 = 0;
reg [15:0] colourofhands = 0;
reg bothswitches = 0;

//game3 registers
reg[12:0] peak3 = 0;
reg[12:0] curr3 = 0;
reg[31:0] reset_peak_ct3 = 0;
reg[20:0] volume3 = 0;
reg[15:0] bomb_background[0:6143];
reg[15:0] bomb_safe[0:6143];
reg enable_random = 1;
reg next = 0; //indicate next bomb
reg[3:0] fire = 0;
reg[15:0] led_bomb = 0;
reg open[14:0];
integer i;
initial begin
    for (i = 0; i <= 14; i = i + 1) begin open[i] = 0; end
end
reg[3:0] try = 0;
reg[20:0] ct_4s = 0;
reg game3_over = 0;
reg[20:0] help = 0;
reg[1:0] safe = 2;
reg[3:0] an_game3 = 4'b1111;
reg[6:0] seg_game3 = 0;
reg[2:0] ct_an3 = 0;

//game 4 registers
reg[15:0] godzilla[0:6143], winner_god[0:6143], winner_gig[0:6143];
reg[15:0] GODBEAM_INNER_COLOUR = 16'hC7BE; //light blue
reg[15:0] GODBEAM_OUTER_COLOUR = 16'h001F; //blue
reg[15:0] GIGBEAM_INNER_COLOUR = 16'hF75C; //light red
reg[15:0] GIGBEAM_OUTER_COLOUR = 16'hF800; //red
reg[7:0] GODSIDE = 48;
reg[2:0] casewinner = 1;
reg[7:0] ct_god = 0;
reg[7:0] ct_gig = 0;
reg[15:0] led_power = 0;
reg shout = 0;
reg[1:0] tiebreaker = 0;
reg[15:0] ct_discharge = 0;
reg[15:0] ct_celeb = 0;
reg[3:0] an_game4 = 4'b1111;
reg[6:0] seg_game4 = 7'b1111111;
reg[1:0] ct_an4 = 0;
reg[20:0] word = 0;

//Game 0: Menu
always @(posedge clk_25hz) begin
    if (game == 0) begin //allow this only when menu is activated 
        if (pulse_up) begin ct_select <= ct_select - 1; end
        if (pulse_down) begin ct_select <= ct_select + 1; end
        if (pulse_centre) begin
            case (ct_select % 4)
                0: begin game <= 1; end //volume bar display
                1: begin game <= 2; end //pokepet game
                2: begin game <= 3; end //maths dancer game
                3: begin game <= 4; end //monsters' fight game
            endcase
        end
    end
    if (sw[15]) begin ct_select <= 64; game <= 0; end //reset ct_select and game
end

//welcome display
always @(posedge clk_381hz) begin
    if (game == 0) begin
        case(ct_an0) 
            0: begin
                //welcome" "" "" "
                an_game0 <= 4'b1110;
                case(welcome/152 % 10)
                    0: begin seg_game0 <= 7'b1010101; end
                    1: begin seg_game0 <= 7'b0000110; end
                    2: begin seg_game0 <= 7'b1000111; end
                    3: begin seg_game0 <= 7'b1000110; end
                    4: begin seg_game0 <= 7'b1000000; end
                    5: begin seg_game0 <= 7'b1101010; end
                    6: begin seg_game0 <= 7'b0000110; end
                    7: begin seg_game0 <= 7'b1111111; end
                    8: begin seg_game0 <= 7'b1111111; end
                    9: begin seg_game0 <= 7'b1111111; end
                endcase
            end
            1: begin
                an_game0 <= 4'b1101;
                case(welcome/152 % 10)
                    1: begin seg_game0 <= 7'b1010101; end
                    2: begin seg_game0 <= 7'b0000110; end
                    3: begin seg_game0 <= 7'b1000111; end
                    4: begin seg_game0 <= 7'b1000110; end
                    5: begin seg_game0 <= 7'b1000000; end
                    6: begin seg_game0 <= 7'b1101010; end
                    7: begin seg_game0 <= 7'b0000110; end
                    8: begin seg_game0 <= 7'b1111111; end
                    9: begin seg_game0 <= 7'b1111111; end
                    0: begin seg_game0 <= 7'b1111111; end
                endcase
            end
            2: begin
                an_game0 <= 4'b1011;
                case(welcome/152 % 10)
                    2: begin seg_game0 <= 7'b1010101; end
                    3: begin seg_game0 <= 7'b0000110; end
                    4: begin seg_game0 <= 7'b1000111; end
                    5: begin seg_game0 <= 7'b1000110; end
                    6: begin seg_game0 <= 7'b1000000; end
                    7: begin seg_game0 <= 7'b1101010; end
                    8: begin seg_game0 <= 7'b0000110; end
                    9: begin seg_game0 <= 7'b1111111; end
                    0: begin seg_game0 <= 7'b1111111; end
                    1: begin seg_game0 <= 7'b1111111; end
                endcase
            end
            3: begin
                an_game0 <= 4'b0111;
                case(welcome/152 % 10)
                    3: begin seg_game0 <= 7'b1010101; end
                    4: begin seg_game0 <= 7'b0000110; end
                    5: begin seg_game0 <= 7'b1000111; end
                    6: begin seg_game0 <= 7'b1000110; end
                    7: begin seg_game0 <= 7'b1000000; end
                    8: begin seg_game0 <= 7'b1101010; end
                    9: begin seg_game0 <= 7'b0000110; end
                    0: begin seg_game0 <= 7'b1111111; end
                    1: begin seg_game0 <= 7'b1111111; end
                    2: begin seg_game0 <= 7'b1111111; end
                endcase
            end
        endcase
        case(welcome / 152 % 10)
            0: begin led_game0 <= 16'b0000_0000_0000_0000 ; end
            1: begin led_game0 <= 16'b1000_0000_0000_0001 ; end
            2: begin led_game0 <= 16'b0100_0000_0000_0010 ; end
            3: begin led_game0 <= 16'b1010_0000_0000_0101 ; end
            4: begin led_game0 <= 16'b0101_0000_0000_1010 ; end
            5: begin led_game0 <= 16'b1010_1000_0001_0101 ; end
            6: begin led_game0 <= 16'b0101_0100_0010_0000 ; end
            7: begin led_game0 <= 16'b1010_1010_0101_0101 ; end
            8: begin led_game0 <= 16'b0101_0101_1010_0101 ; end
            9: begin led_game0 <= 16'b1111_1111_1111_1111 ; end
            
        endcase
        ct_an0 <= ct_an0 + 1;
        welcome <= welcome + 1;
        if (sw[15]) begin welcome <= 0; ct_an0 <= 0; an_game0 <= 4'b1111; seg_game0 <= 7'b1111111; end
    end
end

/*------------------------------------------------------------------------------------------------------------------------------------------------------*/
//Game 1: Volume Bar
//peak algorithm
always @(posedge clk_3p125Mhz) begin
    if (game == 1) begin
        reset_peak_ct1 <= reset_peak_ct1 + 1;
        if (sw[0]) led_npeak <= mic_in; 
        else begin
            curr1 <= mic_in;
            if (curr1 > peak1) peak1 <= curr1;
        end
        //every 0.2s reset the peak value
        if (reset_peak_ct1 == 625001) begin 
            peak1 <= 0;
            reset_peak_ct1 <= 0;
        end
        if (sw[15]) begin peak1 <= 0; reset_peak_ct1 <= 0; led_npeak <= 0; curr1 <= 0; end
    end
end

/**led control for loudness**/
always @(posedge clk_5hz) begin
    if (game == 1) begin
        if (!sw[0]) begin
            case(peak1/128)
                16: begin led_peak <= 16'b0000_0000_0000_0001; volume1 = 0; end
                17: begin led_peak <= 16'b0000_0000_0000_0011; volume1 = 1; end
                18: begin led_peak <= 16'b0000_0000_0000_0111; volume1 = 2; end
                19: begin led_peak <= 16'b0000_0000_0000_1111; volume1 = 3; end
                20: begin led_peak <= 16'b0000_0000_0001_1111; volume1 = 4; end
                21: begin led_peak <= 16'b0000_0000_0011_1111; volume1 = 5; end
                22: begin led_peak <= 16'b0000_0000_0111_1111; volume1 = 6; end
                23: begin led_peak <= 16'b0000_0000_1111_1111; volume1 = 7; end
                24: begin led_peak <= 16'b0000_0001_1111_1111; volume1 = 8; end
                25: begin led_peak <= 16'b0000_0011_1111_1111; volume1 = 9; end
                26: begin led_peak <= 16'b0000_0111_1111_1111; volume1 = 10; end
                27: begin led_peak <= 16'b0000_1111_1111_1111; volume1 = 11; end
                28: begin led_peak <= 16'b0001_1111_1111_1111; volume1 = 12; end
                29: begin led_peak <= 16'b0011_1111_1111_1111; volume1 = 13; end
                30: begin led_peak <= 16'b0111_1111_1111_1111; volume1 = 14; end
                31: begin led_peak <= 16'b1111_1111_1111_1111; volume1 = 15; end
                default: begin
                    if (mic_in/128 > 16) led_peak <= 16'b1111_1111_1111_1111; 
                end
            endcase
       end
       if (sw[15]) begin led_peak <= 0; volume1 <= 0; end
   end 
end

/**segment display**/
always @(posedge clk_381hz)begin
    if (game == 1) begin
        ct_seg <= ct_seg + 1;
        case (ct_seg) 
            0: begin 
                if (volume1 < 6) begin //5
                    an_game1 <= 4'b0111; 
                    seg_game1 <= 7'b1000111;
                end
                else if (volume1 >= 6 && volume1 < 11) begin
                    an_game1 <= 4'b0111;
                    seg_game1 <= 7'b1101010;
                end
                else begin
                    an_game1 <= 4'b0111;
                    seg_game1 <= 7'b0001001;
                end
            end
            1: begin
                if (volume1 >= 11) begin
                    an_game1 <= 4'b1101;
                    seg_game1 <= 7'b1111001;
                end
            end
            2: begin
                ct_seg <= 0;
                case(volume1 % 10)
                    0: begin an_game1 <= 4'b1110; seg_game1 <= 7'b1000000; end
                    1: begin an_game1 <= 4'b1110; seg_game1 <= 7'b1111001; end
                    2: begin an_game1 <= 4'b1110; seg_game1 <= 7'b0100100; end
                    3: begin an_game1 <= 4'b1110; seg_game1 <= 7'b0110000; end
                    4: begin an_game1 <= 4'b1110; seg_game1 <= 7'b0011001; end
                    5: begin an_game1 <= 4'b1110; seg_game1 <= 7'b0010010; end
                    6: begin an_game1 <= 4'b1110; seg_game1 <= 7'b0000010; end
                    7: begin an_game1 <= 4'b1110; seg_game1 <= 7'b1111000; end
                    8: begin an_game1 <= 4'b1110; seg_game1 <= 7'b0000000; end
                    9: begin an_game1 <= 4'b1110; seg_game1 <= 7'b0010000; end
                endcase
            end
        endcase
        if (sw[15]) begin an_game1 <= 4'b1111; seg_game1 <= 7'b1111111; end
    end
end

//volume bar shifting
always @(posedge clk_25hz) begin
    if (game == 1) begin
        if (pulse_right) begin 
            if (upperbound < 95)begin
                lowerbound <= lowerbound + 1;
                upperbound <= upperbound + 1;
            end
        end
        if (pulse_left) begin
            if (lowerbound > 0)begin
                lowerbound <= lowerbound - 1;
                upperbound <= upperbound - 1;
             end
        end
        if (sw[15]) begin lowerbound <= 40; upperbound <= 56; end
    end
end

/*----------------------------------------------------------------------------------------------------------------------------------------*/
//game 2 
initial begin //volume 0-7: clasroom, volume 8-15: underwater, sw5 = peppapig, sw6 = minion//
    $readmemh("ppincr.mem", ppincr);
    $readmemh("mincr.mem", mincr);
    $readmemh("ppinw.mem", ppinw);
    $readmemh("minw.mem", minw);
end

always @(posedge clk_25hz) begin
    if (game == 2) begin
        if (pulse_right) begin
            mathsselect <= mathsselect + 1;
        end
        else if (pulse_left) begin
            mathsselect <= mathsselect - 1;      
        end
        if (sw[15]) begin mathsselect <= 3600; end
    end
end

always @(posedge clk_3p125Mhz) begin
    if (game == 2) begin
        reset_peak_ct2 <= reset_peak_ct2 + 1;
            curr2 = mic_in;
            if (curr2 > peak2) begin
                peak2 = curr2;
            end
        if (reset_peak_ct2 == 625001) begin
            peak2 <= 0;
            reset_peak_ct2 <= 0;
        end
    end
    if (sw[15]) begin curr2 <= 0; reset_peak_ct2 <= 0; peak2 <= 0; end
end

always @(posedge clk_5hz) begin
    if (game == 2) begin
        case(peak2/128) 
            16: begin volume2 = 0; led_peak2 <= 16'b0000_0000_0000_0001; end
            17: begin volume2 = 1; led_peak2 <= 16'b0000_0000_0000_0011; end
            18: begin volume2 = 2; led_peak2 <= 16'b0000_0000_0000_0111; end
            19: begin volume2 = 3; led_peak2 <= 16'b0000_0000_0000_1111; end
            20: begin volume2 = 4; led_peak2 <= 16'b0000_0000_0001_1111; end
            21: begin volume2 = 5; led_peak2 <= 16'b0000_0000_0011_1111; end
            22: begin volume2 = 6; led_peak2 <= 16'b0000_0000_0111_1111; end
            23: begin volume2 = 7; led_peak2 <= 16'b0000_0000_1111_1111; end
            24: begin volume2 = 8; led_peak2 <= 16'b0000_0001_1111_1111; end
            25: begin volume2 = 9; led_peak2 <= 16'b0000_0011_1111_1111; end
            26: begin volume2 = 10;led_peak2 <= 16'b0000_0111_1111_1111;  end
            27: begin volume2 = 11;led_peak2 <= 16'b0000_1111_1111_1111;  end
            28: begin volume2 = 12;led_peak2 <= 16'b0001_1111_1111_1111;  end
            29: begin volume2 = 13;led_peak2 <= 16'b0011_1111_1111_1111;  end
            30: begin volume2 = 14;led_peak2 <= 16'b0111_1111_1111_1111;  end
            31: begin volume2 = 15;led_peak2 <= 16'b1111_1111_1111_1111;  end
        endcase
    end
end

always @(posedge clk_381hz)begin
    if (game == 2) begin
        ct_an2 <= ct_an2 + 1;
        if (bothswitches) begin
            case(ct_an2) //print fail
                 0: begin an_game2 <= 4'b0111; seg_game2 <= 7'b0001110; end
                 1: begin an_game2 <= 4'b1011; seg_game2 <= 7'b0001000; end
                 2: begin an_game2 <= 4'b1101; seg_game2 <= 7'b1001111; end
                 3: begin ct_an2 <= 0; an_game2 <= 4'b1110; seg_game2 <= 7'b1000111; end
                 default : ct_an2 <= 0;
            endcase
        end
        else begin
            case(mathsselect % 6)
                0: begin 
                       case(ct_an2) //LINE
                          0: begin an_game2 <= 4'b0111; seg_game2 <= 7'b1000111; end
                          1: begin an_game2 <= 4'b1011; seg_game2 <= 7'b1001111; end
                          2: begin an_game2 <= 4'b1101; seg_game2 <= 7'b0101011; end
                          3: begin an_game2 <= 4'b1110; seg_game2 <= 7'b0000110; end
                          default: ct_an2 <= 0 ;
                      endcase
                end
                1: begin 
                       case(ct_an2) //SQR 
                          0: begin an_game2 <= 4'b0111; seg_game2 <= 7'b0010010; end
                          1: begin an_game2 <= 4'b1011; seg_game2 <= 7'b0011000; end
                          2: begin an_game2 <= 4'b1101; seg_game2 <= 7'b0101111; end
                          default: ct_an2 <= 0 ;
                      endcase
                end
                2:begin 
                      case(ct_an2) //CUBE
                         0: begin an_game2 <= 4'b0111; seg_game2 <= 7'b0100111; end
                         1: begin an_game2 <= 4'b1011; seg_game2 <= 7'b1100011; end
                         2: begin an_game2 <= 4'b1101; seg_game2 <= 7'b0000011; end
                         3: begin an_game2 <= 4'b1110; seg_game2 <= 7'b0000110; end
                         default: ct_an2 <= 0 ;
                     endcase
                end
                3:begin 
                       case(ct_an2) //SIN
                          0: begin an_game2 <= 4'b0111; seg_game2 <= 7'b0010010; end
                          1: begin an_game2 <= 4'b1011; seg_game2 <= 7'b1001111; end
                          2: begin an_game2 <= 4'b1101; seg_game2 <= 7'b0101011; end
                          default: ct_an2 <= 0 ;
                      endcase
                end
                4:begin 
                       case(ct_an2) //COS
                          0: begin an_game2 <= 4'b0111; seg_game2 <= 7'b0100111; end
                          1: begin an_game2 <= 4'b1011; seg_game2 <= 7'b0100011; end
                          2: begin an_game2 <= 4'b1101; seg_game2 <= 7'b0010010; end
                          default: ct_an2 <= 0 ;
                      endcase
                end
                5:begin 
                     case(ct_an2) //CIRC
                        0: begin an_game2 <= 4'b0111; seg_game2 <= 7'b0100111; end
                        1: begin an_game2 <= 4'b1011; seg_game2 <= 7'b1001111; end  
                        2: begin an_game2 <= 4'b1101; seg_game2 <= 7'b0101111; end
                        3: begin an_game2 <= 4'b1110; seg_game2 <= 7'b0100111; end
                        default: ct_an2 <= 0 ;
                     endcase
                end  
            endcase
        end
        if (sw[15]) begin an_game2 <= 4'b1111; ct_an2 <= 0; end
    end
end

/*----------------------------------------------------------------------------------------------------------------------------------*/
//game 3
initial begin
    $readmemh("bomb_background.mem", bomb_background);
    $readmemh("bomb_safe.mem", bomb_safe);
end

//generate the fire number (haven't completed)
always @(posedge clk_100hz) begin
    if (game == 3 && !sw) begin
        if (enable_random == 1) begin
            fire <= {fire[2], fire[1], fire[0], ~(fire[3] ^ fire[2])}; //random number generator
            enable_random <= 0;
        end
        if (next == 1) enable_random <= 1;
    end
end 

//switches controls
always @(posedge clk_100hz) begin
    if (game == 3) begin
        if (next == 1) begin //restart game
            led_bomb = 0; ct_4s = 0; safe = 2; next = 0; try = 0;
            open[0] = 0; open[1] = 0; open[2] = 0; open[3] = 0; open[4] = 0; open[5] = 0; open[6] = 0; open[7] = 0; 
            open[8] = 0; open[9] = 0; open[10]= 0; open[11] = 0; open[12] = 0; open[13] = 0; open[14] = 0;
        end 
        led_bomb <= sw; //turn on any switches will also activate the led
        if (sw[0]) open[0] <= 1; if (sw[1]) open[1] <= 1;
        if (sw[2]) open[2] <= 1;
        if (sw[3]) open[3] <= 1;
        if (sw[4]) open[4] <= 1;
        if (sw[5]) open[5] <= 1;
        if (sw[6]) open[6] <= 1;
        if (sw[7]) open[7] <= 1;
        if (sw[8]) open[8] <= 1;
        if (sw[9]) open[9] <= 1;
        if (sw[10]) open[10] <= 1;
        if (sw[11]) open[11] <= 1;
        if (sw[12]) open[12] <= 1;
        if (sw[13]) open[13] <= 1;
        if (sw[14]) open[14] <= 1;
        try = open[0] + open[1] + open[2] + open[3] + open[4] + open[5] + open[6] + open[7] + open[8] + open[9] + open[10] + open[11] + open[12] + open[13] + open[14];
        if (try >= 4 && open[fire] == 0) begin safe <= 1; end 
        if (safe == 1 && !sw) begin next <= 1; end
        if (open[fire]) begin
            ct_4s <= ct_4s + 1; //start counting for 4 seconds
            led_bomb[fire] <=(ct_4s % 20 == 0)? ~led_bomb[fire] : led_bomb[fire]; //flash the led every 0.2s
            safe = 0;
            if (safe == 0) begin 
                if (help / 50 >= 3) begin safe <= 1; open[fire] <= 0; end
                else if (ct_4s >= 400) begin game3_over <= 1; end
            end
        end
        if (sw[15]) begin game3_over <= 0; led_bomb <= 0; ct_4s <= 0; safe <= 2; 
            open[0] <= 0; open[1] <= 0; open[2] <= 0; open[3] <= 0; open[4] <= 0; open[5] <= 0; open[6] <= 0; open[7] <= 0; 
            open[8] <= 0; open[9] <= 0; open[10] <= 0; open[11] <= 0; open[12] <= 0; open[13] <= 0; open[14] <= 0;
        end
    end
end

//peak finding algorithm
always @(posedge clk_3p125Mhz) begin
    if (game == 3 && ct_4s > 0) begin
        reset_peak_ct3 <= reset_peak_ct3 + 1;
        curr3 = mic_in;
        if (curr3 > peak3) begin
            peak3 = curr3;
        end
        //every 0.2s reset the peak value
        if (reset_peak_ct3 == 1562501) begin 
            peak3 <= 0;
            reset_peak_ct3 <= 0;
        end
    end
end

always @(posedge clk_100hz) begin
    if (game == 3) begin
        if (ct_4s > 0 && game3_over == 0) begin
            if (peak3 / 128 > 30) begin help <= help + 1; end
        end
        if (sw[15] || next == 1) help <= 0; 
    end 
end

//segment display
always @(posedge clk_381hz) begin
    if (game == 3) begin
        if (ct_4s > 0 && safe == 0) begin
            ct_an3 <= ct_an3 + 1;
            case(ct_an3) 
               0: begin 
                  an_game3 <= 4'b0111;
                  if (ct_4s / 100 == 0) begin seg_game3 <= 7'b0011001; end //4
                  if (ct_4s / 100 == 1) begin seg_game3 <= 7'b0110000; end
                  if (ct_4s / 100 == 2) begin seg_game3 <= 7'b0100100; end
                  if (ct_4s / 100 == 3) begin seg_game3 <= 7'b1111001; end 
               end
               1: begin
                  if (help/50 >= 3) begin an_game3 <= 4'b1000; seg_game3 <= 7'b0001001; end
               end
               2: begin
                  if (help/50 == 2) begin an_game3 <= 4'b1100; seg_game3 <= 7'b0001001; end
               end
               3: begin
                  if (help/50 == 1) begin an_game3 <= 4'b1110; seg_game3 <= 7'b0001001; end
               end
            endcase
        end
        //show "FAIL"
        if (game3_over == 1) begin
            ct_an3 <= ct_an3 + 1; //for four anode displays
            case(ct_an3)
                0: begin an_game3 <= 4'b0111; seg_game3 <= 7'b0001110; end
                1: begin an_game3 <= 4'b1011; seg_game3 <= 7'b0001000; end
                2: begin an_game3 <= 4'b1101; seg_game3 <= 7'b1001111; end
                3: begin ct_an3 <= 0; an_game3 <= 4'b1110; seg_game3 <= 7'b1000111; end
            endcase
        end
        //show "SAFE"
        if (safe == 1) begin
            ct_an3 <= ct_an3 + 1;
            case(ct_an3) 
                0: begin an_game3 <= 4'b0111; seg_game3 <= 7'b0010010; end
                1: begin an_game3 <= 4'b1011; seg_game3 <= 7'b0001000; end
                2: begin an_game3 <= 4'b1101; seg_game3 <= 7'b0001110; end
                3: begin 
                    an_game3 <= 4'b1110; seg_game3 <= 7'b0000110; 
                    if (sw && !sw[15]) begin ct_an3 <= 0; end   
                end
                default: begin an_game3 <= 4'b1111; end
            endcase
        end
        if (sw[15]) begin an_game3 <= 4'b1111; ct_an3 <= 0; end
        if (next == 1) begin an_game3 <= 4'b1111; ct_an3 <= 0; end
    end
end 

/*-----------------------------------------------------------------------------------------------------------------------------------*/
//game 4 controls
always @(posedge clk_25hz) begin
    if (game == 4) begin
        if (casewinner == 1) begin
            if (tiebreaker == 0 && ct_god >= 40) begin tiebreaker = 1; end
            if (tiebreaker == 0 && ct_gig >= 40) begin tiebreaker = 2; end
            if (GODSIDE == 73) begin casewinner <= 2; end
            if (pulse_left == 1) begin 
                GODSIDE = GODSIDE + 1;
                ct_god <= ct_god + 1;
            end
            if (GODSIDE == 24) begin casewinner <= 3; end
            if (pulse_right == 1) begin  
                GODSIDE = GODSIDE - 1;
                ct_gig <= ct_gig + 1;
            end
            case(ct_god/5)
                0: begin led_power = led_power | 0; end
                1: begin led_power = led_power | 16'b0000_0001_0000_0000; end
                2: begin led_power = led_power | 16'b0000_0011_0000_0000; end
                3: begin led_power = led_power | 16'b0000_0111_0000_0000; end
                4: begin led_power = led_power | 16'b0000_1111_0000_0000; end
                5: begin led_power = led_power | 16'b0001_1111_0000_0000; end
                6: begin led_power = led_power | 16'b0011_1111_0000_0000; end
                7: begin led_power = led_power | 16'b0111_1111_0000_0000; end
                8: begin led_power = led_power | 16'b1111_1111_0000_0000; end
            endcase
            case(ct_gig/5)
                0: begin led_power = led_power | 0; end
                1: begin led_power = led_power | 16'b0000_0000_1000_0000; end
                2: begin led_power = led_power | 16'b0000_0000_1100_0000; end
                3: begin led_power = led_power | 16'b0000_0000_1110_0000; end
                4: begin led_power = led_power | 16'b0000_0000_1111_0000; end
                5: begin led_power = led_power | 16'b0000_0000_1111_1000; end
                6: begin led_power = led_power | 16'b0000_0000_1111_1100; end
                7: begin led_power = led_power | 16'b0000_0000_1111_1110; end
                8: begin led_power = led_power | 16'b0000_0000_1111_1111; end               
            endcase
            if (tiebreaker == 1 && shout) begin
                ct_discharge <= ct_discharge + 1;
                case(ct_discharge / 5)
                    0: begin led_power <= 16'b0111_1111_0000_0000; end
                    1: begin led_power <= 16'b0011_1111_0000_0000; end
                    2: begin led_power <= 16'b0001_1111_0000_0000; end
                    3: begin led_power <= 16'b0000_1111_0000_0000; end
                    4: begin led_power <= 16'b0000_0111_0000_0000; end
                    5: begin led_power <= 16'b0000_0011_0000_0000; end
                    6: begin led_power <= 16'b0000_0001_0000_0000; end
                    7: begin led_power <= 16'b0000_0000_0000_0000; casewinner <= 2; end
                endcase
            end
            if (tiebreaker == 2 && shout) begin
                ct_discharge <= ct_discharge + 1;
                case(ct_discharge / 5)
                    0: begin led_power <= 16'b0000_0000_1111_1110; end
                    1: begin led_power <= 16'b0000_0000_1111_1100; end
                    2: begin led_power <= 16'b0000_0000_1111_1000; end
                    3: begin led_power <= 16'b0000_0000_1111_0000; end
                    4: begin led_power <= 16'b0000_0000_1110_0000; end
                    5: begin led_power <= 16'b0000_0000_1100_0000; end
                    6: begin led_power <= 16'b0000_0000_1000_0000; end
                    7: begin led_power <= 16'b0000_0000_0000_0000; casewinner <= 3; end
                endcase
            end  
        end
        if (casewinner == 2) begin
            ct_celeb <= ct_celeb + 1;
           case(ct_celeb % 16) 
                0:begin led_power <= 16'b0000_0001_1000_0000 ; end
                1:begin led_power <= 16'b0000_0011_1100_0000 ; end
                2:begin led_power <= 16'b0000_0111_1110_0000 ; end
                3:begin led_power <= 16'b0000_1111_1111_0000 ; end
                4:begin led_power <= 16'b0001_1111_1111_1000 ; end
                5:begin led_power <= 16'b0011_1111_1111_1100 ; end
                6:begin led_power <= 16'b0111_1111_1111_1110 ; end
                7:begin led_power <= 16'b1111_1111_1111_1111 ; end
                8:begin led_power <= 16'b0111_1111_1111_1110 ; end
                9:begin led_power <= 16'b0011_1111_1111_1100 ; end
                10: begin  led_power <= 16'b0001_1111_1111_1000 ; end
                11: begin  led_power <= 16'b0000_1111_1111_0000 ; end
                12: begin  led_power <= 16'b0000_0111_1110_0000 ; end
                13: begin  led_power <= 16'b0000_0011_1100_0000 ; end
                14: begin  led_power <= 16'b0000_0001_1000_0000 ; end
                15: begin  led_power <= 16'b0000_0000_0000_0000 ; end
           endcase 
        end
        if (casewinner == 3) begin
            ct_celeb <= ct_celeb + 1;
            case(ct_celeb % 16)
                0:  begin led_power <= 16'b1000_0000_0000_0001 ;end
                1:  begin led_power <= 16'b1100_0000_0000_0011 ;end
                2:  begin led_power <= 16'b1110_0000_0000_0111 ;end
                3:  begin led_power <= 16'b1111_0000_0000_1111 ;end
                4:  begin led_power <= 16'b1111_1000_0001_1111 ;end
                5:  begin led_power <= 16'b1111_1100_0011_1111 ;end
                6:  begin led_power <= 16'b1111_1110_0111_1111 ;end
                7:  begin led_power <= 16'b1111_1111_1111_1111 ;end
                8:  begin led_power <= 16'b1111_1110_0111_1111 ;end
                9:  begin led_power <= 16'b1111_1100_0011_1111 ;end
                10: begin led_power <= 16'b1111_1000_0001_1111 ;end
                11: begin led_power <= 16'b1111_0000_0000_1111 ;end
                12: begin led_power <= 16'b1110_0000_0000_0111 ;end
                13: begin led_power <= 16'b1100_0000_0000_0011 ;end
                14: begin led_power <= 16'b1000_0000_0000_0001 ;end
                15: begin led_power <= 16'b0000_0000_0000_0000 ;end
            endcase
        end
        if (sw[15]) begin casewinner <= 1; GODSIDE <= 48; ct_god <= 0; ct_gig <= 0; led_power <= 0; tiebreaker = 0; ct_discharge <= 0; end
    end
end

//segment display
always @(posedge clk_381hz) begin
    if (game == 4) begin
        /*if (casewinner == 2 || casewinner == 3) begin*/ an_game4 <= 4'b1111; seg_game4 <= 7'b1111111; //end 
        if (tiebreaker == 1) begin
            //godzilla wins
            word <= word + 1;
            case((word / 191) % 3) //show which word
                0: begin
                    case(ct_an4)
                        0: begin an_game4 <= 4'b0111; seg_game4 <= 7'b0010000; end //godz
                        1: begin an_game4 <= 4'b1011; seg_game4 <= 7'b1000000; end
                        2: begin an_game4 <= 4'b1101; seg_game4 <= 7'b0100001; end
                        3: begin an_game4 <= 4'b1110; seg_game4 <= 7'b0100100; end
                    endcase
                end
                1: begin
                    case(ct_an4)
                        0: begin an_game4 <= 4'b0111; seg_game4 <= 7'b0001110; end //full
                        1: begin an_game4 <= 4'b1011; seg_game4 <= 7'b1000001; end
                        2: begin an_game4 <= 4'b1101; seg_game4 <= 7'b1000111; end
                        3: begin an_game4 <= 4'b1110; seg_game4 <= 7'b1000111; end
                    endcase     
                end
                2: begin
                    case(ct_an4)
                        0: begin an_game4 <= 4'b0111; seg_game4 <= 7'b0000011; end //beam
                        1: begin an_game4 <= 4'b1011; seg_game4 <= 7'b0000110; end
                        2: begin an_game4 <= 4'b1101; seg_game4 <= 7'b0001000; end
                        3: begin an_game4 <= 4'b1110; seg_game4 <= 7'b1101010; end        
                    endcase     
                end
            endcase
            ct_an4 <= ct_an4 + 1;
        end
        else if (tiebreaker == 2) begin
             word <= word + 1;
             case((word / 191) % 3) //show which word
                0: begin
                    case(ct_an4)
                        0: begin an_game4 <= 4'b0111; seg_game4 <= 7'b0010000; end //giga
                        1: begin an_game4 <= 4'b1011; seg_game4 <= 7'b1001111; end
                        2: begin an_game4 <= 4'b1101; seg_game4 <= 7'b0010000; end
                        3: begin an_game4 <= 4'b1110; seg_game4 <= 7'b0001000; end
                    endcase
                end
                1: begin
                    case(ct_an4)
                        0: begin an_game4 <= 4'b0111; seg_game4 <= 7'b0001110; end //full
                        1: begin an_game4 <= 4'b1011; seg_game4 <= 7'b1000001; end
                        2: begin an_game4 <= 4'b1101; seg_game4 <= 7'b1000111; end
                        3: begin an_game4 <= 4'b1110; seg_game4 <= 7'b1000111; end
                    endcase     
                end
                2: begin
                    case(ct_an4)
                        0: begin an_game4 <= 4'b0111; seg_game4 <= 7'b0000011; end //beam
                        1: begin an_game4 <= 4'b1011; seg_game4 <= 7'b0000110; end
                        2: begin an_game4 <= 4'b1101; seg_game4 <= 7'b0001000; end
                        3: begin an_game4 <= 4'b1110; seg_game4 <= 7'b1101010; end        
                    endcase     
                end
            endcase
            ct_an4 <= ct_an4 + 1;
            if (sw[15]) begin an_game4 <= 4'b1111; seg_game4 <= 7'b1111111; ct_an4 <= 0; word <= 0; end
        end
        if (casewinner == 2 || casewinner == 3) begin an_game4 <= 4'b1111; seg_game4 <= 7'b1111111; end
    end
end

//detect sound
always @(posedge clk_3p125Mhz) begin
    if (game == 4 && (ct_god >= 40 || ct_gig >= 40) && mic_in / 128 > 30) begin shout = 1; end
    if (sw[15]) begin shout = 0; end
end

initial begin
    $readmemh("mainmenu.mem", mainmenu);
    $readmemh("INVERTED_mainmenu.mem", INVERTED_mainmenu);
    $readmemh("godzilla.mem", godzilla);
    $readmemh("winner_god.mem", winner_god);
    $readmemh("winner_gig.mem", winner_gig);
end

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
//main OLED displays
always @(posedge clk_3p125Mhz) begin
    //game 0: menu display
    if (game == 0) begin
        pix_data <= mainmenu[my_pix_index];
        case(ct_select % 4)
            0: begin 
                if (y >= 13 && y <= 25) begin pix_data <= INVERTED_mainmenu[my_pix_index]; end
               end
            1: begin
                if (y >= 26 && y <= 38) begin pix_data <= INVERTED_mainmenu[my_pix_index]; end
               end
            2: begin
                if (y >= 39 && y <= 50) begin pix_data <= INVERTED_mainmenu[my_pix_index]; end
               end
            3: begin
                if (y >= 51 && y <= 63) begin pix_data <= INVERTED_mainmenu[my_pix_index]; end
               end
        endcase
    end
    /*----------------------------------------------------------------------------------------------------------------------------------------------------------*/
    //game 1: volume bar displa
    if (game == 1) begin
        if (sw[14]) begin 
            LOWCOLOUR <= 16'hF800;
            MEDCOLOUR <= 16'b00000_000000_11111;
            HIGHCOLOUR <= 16'h3FFF;
            BACKGD_COLOUR <= 16'hFFFF;
            BOARDER_COLOUR <= 16'b11111_111111_00000;
        end
        else begin
            LOWCOLOUR <= 16'b00000_111111_00000;
            MEDCOLOUR <= 16'b11111_111111_00000;
            HIGHCOLOUR <= 16'b11111_000000_00000;
            BACKGD_COLOUR <= 0;
            BOARDER_COLOUR <= 16'hFFFF;
        end
        pix_data <= BACKGD_COLOUR;
        if (x >= lowerbound && x <= upperbound && sw[3]) begin
           //pix_data <= BACKGD_COLOUR;
           case(volume1)
               0: begin 
                   if (y >= 53 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                 
               end
               1: begin 
                   if (y >= 50 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                    
               end
               2: begin
                   if (y >= 47 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                    
               end
               3: begin
                   if (y >= 44 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end             
               end
               4: begin
                  if (y >= 41 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                                                                                   
               end
               5: begin
                   if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                                          
               end
               6: begin
                   if (y >= 35 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                                                                
               end
               7: begin
                   if (y >= 32 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                                              
               end
               8: begin
                   if (y >= 29 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                                           
               end
               9: begin
                   if (y >= 26 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                                                 
               end
               10: begin
                   if (y >= 23 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                                                        
               end
               11: begin
                   if (y >= 20 && y <= 22) begin pix_data<= HIGHCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 23 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                                                              
               end
               12: begin
                   if (y >= 17 && y <= 22) begin pix_data<= HIGHCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 23 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                       
               end
               13: begin
                   if (y >= 14 && y <= 22) begin pix_data<= HIGHCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 23 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                            
               end
               14: begin
                   if (y >= 11 && y <= 22) begin pix_data<= HIGHCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 23 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end                             
               end
               15: begin
                   if (y >= 8 && y <= 22) begin pix_data<= HIGHCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 23 && y <= 37) begin pix_data<= MEDCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end
                   else if (y >= 38 && y <= 54) begin pix_data<= LOWCOLOUR; if (y % 3 == 2) pix_data<= BACKGD_COLOUR; end           
               end
           endcase
         end    
         //boarder thickness is 1
         if (sw[1]) begin 
            if ( ((x >= 0 && x <= 95) && (y == 0 || y == 63)) || ((y >= 0 && y <= 63) && (x == 0 || x== 95)) ) begin
                pix_data <= BOARDER_COLOUR;
            end
         end
         //boarder thickness is 3
         if (sw[2]) begin
             if ( (((x >= 3 && x <= 95) && (y >= 0 && y <= 2))|| (y >= 61 && y <= 63)) || ((y >= 0 && y <= 63) && ((x >= 0 && x <= 2) || (x >= 93 && x <= 95))) ) begin
                pix_data <= BOARDER_COLOUR;
             end
        end
        if (sw[15]) begin pix_data <= 0; BOARDER_COLOUR <= 16'hFFFF; end
    end
   /*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
   //Game 2: Maths Dancer
   if (game == 2) begin
       if (sw[0] == 0 && sw[1] == 0) begin
           pix_data <= 0;
           bothswitches <= 0;
       end
       else if (sw[0] == 1 && sw[1] == 1) begin
           bothswitches <= 1;
       end
       else if (volume2 > 7 && sw[0] && !sw[1])begin
           pix_data <= ppinw[my_pix_index];
           colourofhands =16'hED79;
           bothswitches <= 0;
       end
       else if (volume2 <= 7 && sw[0] && !sw[1])begin
           pix_data <= ppincr[my_pix_index];
           colourofhands =16'hED79;
           bothswitches <= 0;
       end
       else if (volume2 > 7 && sw[1] && !sw[0])begin
           pix_data <= minw[my_pix_index];
           colourofhands = 16'hF6CD;
           bothswitches <= 0;
       end
       else if (volume2 <= 7 && sw[1] && !sw[0])begin
           pix_data <= mincr[my_pix_index];
           colourofhands = 16'hF6CD;
           bothswitches <= 0;
       end
                  
       if (sw[0] ^ sw[1]) begin
           case(mathsselect % 6)
               0 :/*y=x*/ begin
                  if ( y == 21 && x >= 76 && x <= 77) begin pix_data <= colourofhands; end
                  if ( y == 22 && x >= 75 && x <= 77) begin pix_data <= colourofhands; end
                  if ( y == 23 && x >= 74 && x <= 76) begin pix_data <= colourofhands; end
                  if ( y == 24 && x >= 73 && x <= 75) begin pix_data <= colourofhands; end
                  if ( y == 25 && x >= 71 && x <= 74) begin pix_data <= colourofhands; end
                  if ( y == 26 && x >= 70 && x <= 73) begin pix_data <= colourofhands; end
                  if ( y == 27 && x >= 69 && x <= 72) begin pix_data <= colourofhands; end
                  if ( y == 28 && x >= 67 && x <= 70) begin pix_data <= colourofhands; end
                  if ( y == 29 && x >= 67 && x <= 69) begin pix_data <= colourofhands; end
                  if ( y == 30 && x >= 66 && x <= 68) begin pix_data <= colourofhands; end
                  if ( y == 31 && x >= 64 && x <= 67) begin pix_data <= colourofhands; end
                  if ( y == 32 && x >= 63 && x <= 66) begin pix_data <= colourofhands; end
                  if ( y == 33 && x >= 62 && x <= 65) begin pix_data <= colourofhands; end
                  if ( y == 34 && x >= 61 && x <= 64) begin pix_data <= colourofhands; end
                  if ( y == 35 && x >= 59 && x <= 62) begin pix_data <= colourofhands; end
                  if ( y == 36 && x >= 59 && x <= 61) begin pix_data <= colourofhands; end
                  if ( y == 37 && x >= 58 && x <= 60) begin pix_data <= colourofhands; end
                  if ( y == 38 && x >= 32 && x <= 34) begin pix_data <= colourofhands; end
                  if ( y == 39 && x >= 31 && x <= 33) begin pix_data <= colourofhands; end
                  if ( y == 40 && x >= 30 && x <= 32) begin pix_data <= colourofhands; end
                  if ( y == 41 && x >= 28 && x <= 31 ) begin pix_data <= colourofhands; end
                  if ( y == 42 && x >= 27 && x <= 30) begin pix_data <= colourofhands; end
                  if ( y == 43 && x >= 26 && x <= 28) begin pix_data <= colourofhands; end
                  if ( y == 44 && x >= 25 && x <= 27) begin pix_data <= colourofhands; end
                  if ( y == 45 && x >= 24 && x <= 26) begin pix_data <= colourofhands; end
                  if ( y == 46 && x >= 23 && x <= 25) begin pix_data <= colourofhands; end
                  if ( y == 47 && x >= 21 && x <= 24) begin pix_data <= colourofhands; end
                  if ( y == 48 && x >= 20 && x <= 23) begin pix_data <= colourofhands; end
                  if ( y == 49 && x >= 19 && x <= 22) begin pix_data <= colourofhands; end
                  if ( y == 50 && x >= 18 && x <= 20) begin pix_data <= colourofhands; end
                  if ( y == 51 && x >= 17 && x <= 19) begin pix_data <= colourofhands; end
                  if ( y == 52 && x >= 16 && x <= 18) begin pix_data <= colourofhands; end
                  if ( y == 53 && x >= 15 && x <= 17) begin pix_data <= colourofhands; end
               end
               1 :/*y=x^2*/ begin
                   if ( y == 15 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 16 && x == 16 ) begin pix_data <= colourofhands; end
                   if ( y == 16 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 17 && x >= 16 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 17 && x == 76 ) begin pix_data <= colourofhands; end
                   if ( y == 18 && x >= 16 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 18 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 19 && x >= 16 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 19 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 20 && x >= 16 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 20 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 21 && x >= 16 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 21 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 22 && x >= 16 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 22 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 23 && x >= 16 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 23 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 24 && x >= 17 && x <= 18) begin pix_data <= colourofhands; end
                   if ( y == 24 && x >= 74 && x <= 76) begin pix_data <= colourofhands; end
                   if ( y == 25 && x >= 17 && x <= 18) begin pix_data <= colourofhands; end
                   if ( y == 25 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                   if ( y == 26 && x >= 17 && x <= 18) begin pix_data <= colourofhands; end
                   if ( y == 26 && x >= 73 && x <= 75) begin pix_data <= colourofhands; end
                   if ( y == 27 && x >= 17 && x <= 18) begin pix_data <= colourofhands; end
                   if ( y == 27 && x >= 73 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 28 && x >= 17 && x <= 19) begin pix_data <= colourofhands; end
                   if ( y == 28 && x >= 72 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 29 && x >= 18 && x <= 19) begin pix_data <= colourofhands; end
                   if ( y == 29 && x >= 71 && x <= 73) begin pix_data <= colourofhands; end
                   if ( y == 30 && x >= 18 && x <= 19) begin pix_data <= colourofhands; end
                   if ( y == 30 && x >= 71 && x <= 73) begin pix_data <= colourofhands; end
                   if ( y == 31 && x >= 18 && x <= 20) begin pix_data <= colourofhands; end
                   if ( y == 31 && x >= 70 && x <= 72) begin pix_data <= colourofhands; end
                   if ( y == 32 && x >= 19 && x <= 20) begin pix_data <= colourofhands; end
                   if ( y == 32 && x >= 69 && x <= 71) begin pix_data <= colourofhands; end
                   if ( y == 33 && x >= 19 && x <= 21) begin pix_data <= colourofhands; end
                   if ( y == 33 && x >= 68 && x <= 70) begin pix_data <= colourofhands; end
                   if ( y == 34 && x >= 20 && x <= 22) begin pix_data <= colourofhands; end
                   if ( y == 34 && x >= 67 && x <= 70) begin pix_data <= colourofhands; end
                   if ( y == 35 && x >= 21 && x <= 24) begin pix_data <= colourofhands; end
                   if ( y == 35 && x >= 64 && x <= 68) begin pix_data <= colourofhands; end
                   if ( y == 36 && x >= 22 && x <= 26) begin pix_data <= colourofhands; end
                   if ( y == 36 && x >= 58 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 23 && x <= 28) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 58 && x <= 64) begin pix_data <= colourofhands; end
                   if ( y == 38 && x >= 26 && x <= 34) begin pix_data <= colourofhands; end
                   if ( y == 39 && x >= 29 && x <= 34) begin pix_data <= colourofhands; end
               end
               2 :/*y=x^3*/ begin
                  if ( y == 15 && x == 75 ) begin pix_data <= colourofhands; end
                  if ( y == 16 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                  if ( y == 17 && x >= 75 && x <= 76) begin pix_data <= colourofhands; end
                  if ( y == 18 && x == 75 ) begin pix_data <= colourofhands; end
                  if ( y == 19 && x >= 74 && x <= 76) begin pix_data <= colourofhands; end
                  if ( y == 20 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                  if ( y == 21 && x == 75 ) begin pix_data <= colourofhands; end
                  if ( y == 22 && x == 75 ) begin pix_data <= colourofhands; end
                  if ( y == 23 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                  if ( y == 24 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                  if ( y == 25 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                  if ( y == 26 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                  if ( y == 27 && x >= 73 && x <= 75) begin pix_data <= colourofhands; end
                  if ( y == 28 && x >= 73 && x <= 74) begin pix_data <= colourofhands; end
                  if ( y == 29 && x >= 72 && x <= 74) begin pix_data <= colourofhands; end
                  if ( y == 30 && x >= 71 && x <= 73) begin pix_data <= colourofhands; end
                  if ( y == 31 && x >= 71 && x <= 73) begin pix_data <= colourofhands; end
                  if ( y == 32 && x >= 70 && x <= 72) begin pix_data <= colourofhands; end
                  if ( y == 33 && x >= 69 && x <= 71) begin pix_data <= colourofhands; end
                  if ( y == 34 && x >= 68 && x <= 71) begin pix_data <= colourofhands; end
                  if ( y == 35 && x >= 67 && x <= 69) begin pix_data <= colourofhands; end
                  if ( y == 36 && x >= 58 && x <= 59) begin pix_data <= colourofhands; end
                  if ( y == 36 && x >= 64 && x <= 68) begin pix_data <= colourofhands; end
                  if ( y == 37 && x >= 58 && x <= 67) begin pix_data <= colourofhands; end
                  if ( y == 38 && x == 28 ) begin pix_data <= colourofhands; end
                  if ( y == 38 && x >= 30 && x <= 34) begin pix_data <= colourofhands; end
                  if ( y == 38 && x == 60 ) begin pix_data <= colourofhands; end
                  if ( y == 38 && x == 62 ) begin pix_data <= colourofhands; end
                  if ( y == 38 && x == 64 ) begin pix_data <= colourofhands; end
                  if ( y == 39 && x >= 26 && x <= 34) begin pix_data <= colourofhands; end
                  if ( y == 40 && x >= 25 && x <= 28) begin pix_data <= colourofhands; end
                  if ( y == 41 && x >= 24 && x <= 27) begin pix_data <= colourofhands; end
                  if ( y == 42 && x >= 23 && x <= 26) begin pix_data <= colourofhands; end
                  if ( y == 43 && x >= 22 && x <= 24) begin pix_data <= colourofhands; end
                  if ( y == 44 && x >= 22 && x <= 23) begin pix_data <= colourofhands; end
                  if ( y == 45 && x >= 22 && x <= 23) begin pix_data <= colourofhands; end
                  if ( y == 46 && x >= 21 && x <= 23) begin pix_data <= colourofhands; end
                  if ( y == 47 && x >= 21 && x <= 22) begin pix_data <= colourofhands; end
                  if ( y == 48 && x >= 20 && x <= 22) begin pix_data <= colourofhands; end
                  if ( y == 49 && x >= 20 && x <= 21) begin pix_data <= colourofhands; end
                  if ( y == 50 && x >= 20 && x <= 21) begin pix_data <= colourofhands; end
                  if ( y == 51 && x >= 19 && x <= 21) begin pix_data <= colourofhands; end
                  if ( y == 52 && x >= 19 && x <= 20) begin pix_data <= colourofhands; end
                  if ( y == 53 && x >= 19 && x <= 20) begin pix_data <= colourofhands; end
                  if ( y == 54 && x >= 18 && x <= 19) begin pix_data <= colourofhands; end
                  if ( y == 55 && x >= 18 && x <= 19) begin pix_data <= colourofhands; end
                  if ( y == 56 && x >= 18 && x <= 19) begin pix_data <= colourofhands; end         
               end
               3 :/*y=sinx*/ begin
                   if ( y == 26 && x >= 17 && x <= 24) begin pix_data <= colourofhands; end
                   if ( y == 27 && x >= 16 && x <= 19) begin pix_data <= colourofhands; end
                   if ( y == 27 && x >= 21 && x <= 26) begin pix_data <= colourofhands; end
                   if ( y == 28 && x >= 15 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 28 && x >= 24 && x <= 27) begin pix_data <= colourofhands; end
                   if ( y == 29 && x >= 15 && x <= 17) begin pix_data <= colourofhands; end
                   if ( y == 29 && x >= 25 && x <= 27) begin pix_data <= colourofhands; end
                   if ( y == 30 && x >= 14 && x <= 16) begin pix_data <= colourofhands; end
                   if ( y == 30 && x >= 26 && x <= 28) begin pix_data <= colourofhands; end
                   if ( y == 31 && x >= 13 && x <= 15) begin pix_data <= colourofhands; end
                   if ( y == 31 && x >= 27 && x <= 29) begin pix_data <= colourofhands; end
                   if ( y == 32 && x >= 13 && x <= 14) begin pix_data <= colourofhands; end
                   if ( y == 32 && x >= 28 && x <= 30) begin pix_data <= colourofhands; end
                   if ( y == 33 && x >= 12 && x <= 14) begin pix_data <= colourofhands; end
                   if ( y == 33 && x >= 28 && x <= 30) begin pix_data <= colourofhands; end
                   if ( y == 34 && x >= 11 && x <= 13) begin pix_data <= colourofhands; end
                   if ( y == 34 && x >= 29 && x <= 31) begin pix_data <= colourofhands; end
                   if ( y == 35 && x >= 10 && x <= 12) begin pix_data <= colourofhands; end
                   if ( y == 35 && x >= 30 && x <= 32) begin pix_data <= colourofhands; end
                   if ( y == 36 && x >= 10 && x <= 12) begin pix_data <= colourofhands; end
                   if ( y == 36 && x >= 31 && x <= 33) begin pix_data <= colourofhands; end
                   if ( y == 36 && x >= 59 && x <= 60) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 9 && x <= 11) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 31 && x <= 33) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 58 && x <= 60) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 84 && x <= 85) begin pix_data <= colourofhands; end
                   if ( y == 38 && x >= 8 && x <= 10) begin pix_data <= colourofhands; end
                   if ( y == 38 && x >= 32 && x <= 34) begin pix_data <= colourofhands; end
                   if ( y == 38 && x >= 59 && x <= 61) begin pix_data <= colourofhands; end
                   if ( y == 38 && x >= 84 && x <= 85) begin pix_data <= colourofhands; end
                   if ( y == 39 && x >= 8 && x <= 9) begin pix_data <= colourofhands; end
                   if ( y == 39 && x == 33 ) begin pix_data <= colourofhands; end
                   if ( y == 39 && x >= 60 && x <= 62) begin pix_data <= colourofhands; end
                   if ( y == 39 && x >= 84 && x <= 85) begin pix_data <= colourofhands; end
                   if ( y == 40 && x >= 60 && x <= 62) begin pix_data <= colourofhands; end
                   if ( y == 40 && x >= 83 && x <= 84) begin pix_data <= colourofhands; end
                   if ( y == 41 && x >= 61 && x <= 63) begin pix_data <= colourofhands; end
                   if ( y == 41 && x >= 82 && x <= 84) begin pix_data <= colourofhands; end
                   if ( y == 42 && x >= 62 && x <= 63) begin pix_data <= colourofhands; end
                   if ( y == 42 && x >= 82 && x <= 84) begin pix_data <= colourofhands; end
                   if ( y == 43 && x >= 62 && x <= 64) begin pix_data <= colourofhands; end
                   if ( y == 43 && x >= 81 && x <= 83) begin pix_data <= colourofhands; end
                   if ( y == 44 && x >= 63 && x <= 64) begin pix_data <= colourofhands; end
                   if ( y == 44 && x >= 80 && x <= 82) begin pix_data <= colourofhands; end
                   if ( y == 45 && x >= 63 && x <= 65) begin pix_data <= colourofhands; end
                   if ( y == 45 && x >= 78 && x <= 81) begin pix_data <= colourofhands; end
                   if ( y == 46 && x >= 64 && x <= 66) begin pix_data <= colourofhands; end
                   if ( y == 46 && x >= 77 && x <= 80) begin pix_data <= colourofhands; end
                   if ( y == 47 && x >= 65 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 47 && x >= 75 && x <= 79) begin pix_data <= colourofhands; end
                   if ( y == 48 && x >= 66 && x <= 69) begin pix_data <= colourofhands; end
                   if ( y == 48 && x >= 73 && x <= 77) begin pix_data <= colourofhands; end
                   if ( y == 49 && x >= 67 && x <= 75) begin pix_data <= colourofhands; end
                   if ( y == 50 && x == 69 ) begin pix_data <= colourofhands; end
                   if ( y == 50 && x >= 71 && x <= 73) begin pix_data <= colourofhands; end         
               end
               4 :/*y=cosx*/ begin
                   if ( y == 36 && x >= 58 && x <= 60 ) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 58 && x <= 64) begin pix_data <= colourofhands; end
                   if ( y == 38 && x >= 29 && x <= 34) begin pix_data <= colourofhands; end
                   if ( y == 38 && x >= 61 && x <= 65) begin pix_data <= colourofhands; end
                   if ( y == 39 && x >= 27 && x <= 34) begin pix_data <= colourofhands; end
                   if ( y == 39 && x >= 64 && x <= 66) begin pix_data <= colourofhands; end
                   if ( y == 40 && x >= 26 && x <= 29) begin pix_data <= colourofhands; end
                   if ( y == 40 && x >= 65 && x <= 66) begin pix_data <= colourofhands; end
                   if ( y == 41 && x >= 26 && x <= 28) begin pix_data <= colourofhands; end
                   if ( y == 41 && x >= 65 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 42 && x >= 25 && x <= 27) begin pix_data <= colourofhands; end
                   if ( y == 42 && x == 66 ) begin pix_data <= colourofhands; end
                   if ( y == 43 && x >= 24 && x <= 25) begin pix_data <= colourofhands; end
                   if ( y == 43 && x == 26 ) begin pix_data <= colourofhands; end
                   if ( y == 43 && x >= 66 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 44 && x >= 24 && x <= 26) begin pix_data <= colourofhands; end
                   if ( y == 44 && x >= 66 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 45 && x >= 23 && x <= 25) begin pix_data <= colourofhands; end
                   if ( y == 45 && x >= 66 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 46 && x >= 23 && x <= 25) begin pix_data <= colourofhands; end
                   if ( y == 46 && x >= 66 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 47 && x >= 22 && x <= 24) begin pix_data <= colourofhands; end
                   if ( y == 47 && x >= 66 && x <= 68) begin pix_data <= colourofhands; end
                   if ( y == 48 && x >= 22 && x <= 23) begin pix_data <= colourofhands; end
                   if ( y == 48 && x >= 66 && x <= 68) begin pix_data <= colourofhands; end
                   if ( y == 49 && x >= 21 && x <= 23) begin pix_data <= colourofhands; end
                   if ( y == 49 && x >= 67 && x <= 69) begin pix_data <= colourofhands; end
                   if ( y == 50 && x >= 21 && x <= 22) begin pix_data <= colourofhands; end
                   if ( y == 50 && x >= 68 && x <= 70) begin pix_data <= colourofhands; end
                   if ( y == 51 && x >= 19 && x <= 22) begin pix_data <= colourofhands; end
                   if ( y == 51 && x >= 69 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 52 && (x == 9 || x == 10)) begin pix_data <= colourofhands; end
                   if ( y == 52 && x >= 17 && x <= 21) begin pix_data <= colourofhands; end
                   if ( y == 52 && x >= 70 && x <= 79) begin pix_data <= colourofhands; end
                   if ( y == 53 && x >= 8 && x <= 20) begin pix_data <= colourofhands; end
                   if ( y == 53 && x >= 75 && x <= 78) begin pix_data <= colourofhands; end
                   if ( y == 54 && x >= 10 && x <= 14) begin pix_data <= colourofhands; end
                   if ( y == 54 && x >= 15 && x <= 16 ) begin pix_data <= colourofhands; end                      
               end
               5 :/*circle*/ begin
                   if ( y == 1 && x >= 36 && x <= 44) begin pix_data <= colourofhands; end
                   if ( y == 1 && x >= 50 && x <= 51) begin pix_data <= colourofhands; end
                   if ( y == 1 && x >= 53 && x <= 54) begin pix_data <= colourofhands; end
                   if ( y == 2 && x >= 33 && x <= 44) begin pix_data <= colourofhands; end
                   if ( y == 2 && x >= 50 && x <= 59) begin pix_data <= colourofhands; end
                   if ( y == 3 && x >= 32 && x <= 37) begin pix_data <= colourofhands; end
                   if ( y == 3 && x >= 55 && x <= 61) begin pix_data <= colourofhands; end
                   if ( y == 4 && x >= 30 && x <= 34) begin pix_data <= colourofhands; end
                   if ( y == 4 && x >= 59 && x <= 64) begin pix_data <= colourofhands; end
                   if ( y == 5 && x >= 28 && x <= 32) begin pix_data <= colourofhands; end
                   if ( y == 5 && x >= 62 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 6 && x >= 27 && x <= 30) begin pix_data <= colourofhands; end
                   if ( y == 6 && x >= 64 && x <= 68) begin pix_data <= colourofhands; end
                   if ( y == 7 && x >= 26 && x <= 29) begin pix_data <= colourofhands; end
                   if ( y == 7 && x >= 67 && x <= 69) begin pix_data <= colourofhands; end
                   if ( y == 8 && x >= 25 && x <= 28) begin pix_data <= colourofhands; end
                   if ( y == 8 && x >= 68 && x <= 70) begin pix_data <= colourofhands; end
                   if ( y == 9 && x >= 24 && x <= 27) begin pix_data <= colourofhands; end
                   if ( y == 9 && x >= 69 && x <= 71) begin pix_data <= colourofhands; end
                   if ( y == 10 && x >= 24 && x <= 26) begin pix_data <= colourofhands; end
                   if ( y == 10 && x >= 70 && x <= 71) begin pix_data <= colourofhands; end
                   if ( y == 11 && x >= 23 && x <= 25) begin pix_data <= colourofhands; end
                   if ( y == 11 && x >= 70 && x <= 72) begin pix_data <= colourofhands; end
                   if ( y == 12 && x >= 23 && x <= 24) begin pix_data <= colourofhands; end
                   if ( y == 12 && x >= 71 && x <= 73) begin pix_data <= colourofhands; end
                   if ( y == 13 && x >= 22 && x <= 24) begin pix_data <= colourofhands; end
                   if ( y == 13 && x >= 72 && x <= 73) begin pix_data <= colourofhands; end
                   if ( y == 14 && x >= 22 && x <= 23) begin pix_data <= colourofhands; end
                   if ( y == 14 && x >= 72 && x <= 73) begin pix_data <= colourofhands; end
                   if ( y == 15 && x >= 21 && x <= 23) begin pix_data <= colourofhands; end
                   if ( y == 15 && x >= 73 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 16 && x >= 21 && x <= 22) begin pix_data <= colourofhands; end
                   if ( y == 16 && x >= 73 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 17 && x >= 21 && x <= 22) begin pix_data <= colourofhands; end
                   if ( y == 17 && x >= 73 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 18 && x >= 20 && x <= 22) begin pix_data <= colourofhands; end
                   if ( y == 18 && x >= 73 && x <= 75) begin pix_data <= colourofhands; end
                   if ( y == 19 && x >= 20 && x <= 21) begin pix_data <= colourofhands; end
                   if ( y == 19 && x == 74 ) begin pix_data <= colourofhands; end
                   if ( y == 20 && x >= 20 && x <= 21) begin pix_data <= colourofhands; end
                   if ( y == 20 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                   if ( y == 21 && x >= 19 && x <= 20) begin pix_data <= colourofhands; end
                   if ( y == 21 && x == 74 ) begin pix_data <= colourofhands; end
                   if ( y == 22 && x == 20 ) begin pix_data <= colourofhands; end
                   if ( y == 22 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                   if ( y == 23 && x >= 19 && x <= 20) begin pix_data <= colourofhands; end
                   if ( y == 23 && x >= 74 && x <= 75) begin pix_data <= colourofhands; end
                   if ( y == 24 && x == 20 ) begin pix_data <= colourofhands; end
                   if ( y == 24 && x == 74 ) begin pix_data <= colourofhands; end
                   if ( y == 25 && x >= 19 && x <= 20) begin pix_data <= colourofhands; end
                   if ( y == 25 && x >= 73 && x <= 75) begin pix_data <= colourofhands; end
                   if ( y == 26 && x >= 20 && x <= 21) begin pix_data <= colourofhands; end
                   if ( y == 26 && x >= 73 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 27 && x >= 20 && x <= 21) begin pix_data <= colourofhands; end
                   if ( y == 27 && x >= 73 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 28 && x >= 20 && x <= 22) begin pix_data <= colourofhands; end
                   if ( y == 28 && x >= 72 && x <= 74) begin pix_data <= colourofhands; end
                   if ( y == 29 && x >= 21 && x <= 22) begin pix_data <= colourofhands; end
                   if ( y == 29 && x >= 71 && x <= 73) begin pix_data <= colourofhands; end
                   if ( y == 30 && x >= 21 && x <= 23) begin pix_data <= colourofhands; end
                   if ( y == 30 && x >= 70 && x <= 72) begin pix_data <= colourofhands; end
                   if ( y == 31 && x >= 22 && x <= 24) begin pix_data <= colourofhands; end
                   if ( y == 31 && x >= 69 && x <= 71) begin pix_data <= colourofhands; end
                   if ( y == 32 && x >= 23 && x <= 25) begin pix_data <= colourofhands; end
                   if ( y == 32 && x >= 68 && x <= 70) begin pix_data <= colourofhands; end
                   if ( y == 33 && x >= 23 && x <= 26) begin pix_data <= colourofhands; end
                   if ( y == 33 && x >= 66 && x <= 69) begin pix_data <= colourofhands; end
                   if ( y == 34 && x >= 25 && x <= 27) begin pix_data <= colourofhands; end
                   if ( y == 34 && x >= 65 && x <= 68) begin pix_data <= colourofhands; end
                   if ( y == 35 && x >= 25 && x <= 28) begin pix_data <= colourofhands; end
                   if ( y == 35 && x >= 62 && x <= 67) begin pix_data <= colourofhands; end
                   if ( y == 36 && x >= 27 && x <= 30) begin pix_data <= colourofhands; end
                   if ( y == 36 && x >= 58 && x <= 64) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 28 && x <= 32) begin pix_data <= colourofhands; end
                   if ( y == 37 && x >= 58 && x <= 62) begin pix_data <= colourofhands; end
                   if ( y == 38 && x >= 29 && x <= 34) begin pix_data <= colourofhands; end
                   if ( y == 39 && x >= 32 && x <= 34) begin pix_data <= colourofhands; end                                           
               end
           endcase
       end     
   end
   /*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
   //game 3: Bomb
    if (game == 3) begin
        if (safe == 2 || safe == 0) begin pix_data <= bomb_background[my_pix_index]; end
        if (game3_over) begin pix_data <= 0; end
        if (safe == 1) begin pix_data <= bomb_safe[my_pix_index]; end
    end
    
    /*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    //game 4: King of the Monsters
    if (game == 4) begin
        if (casewinner == 1) begin
            pix_data <= godzilla[my_pix_index];
            if (y == 17 || y == 19) begin
                if (x >= 24 && x <= GODSIDE) begin
                    //outer godzilla
                    pix_data <= GODBEAM_OUTER_COLOUR;
                end
                if (x > GODSIDE && x <= 73) begin
                    //outer gigan
                    pix_data <= GIGBEAM_OUTER_COLOUR;
                end
            end
            if (y == 18) begin
                if (x >= 24 && x <= GODSIDE) begin
                    //inner godzilla
                    pix_data <= GODBEAM_INNER_COLOUR;
                end
                if (x > GODSIDE && x <= 73) begin
                    //inner gigan
                    pix_data <= GIGBEAM_INNER_COLOUR;
                end
            end
        end
        if (casewinner == 2) begin
            //godzilla wins
            pix_data <= winner_god[my_pix_index];
        end
        if (casewinner == 3) begin
            //gigan wins
            pix_data <= winner_gig[my_pix_index];   
        end          
    end
end

assign led = (game == 1)? ((sw[0])? led_npeak : led_peak) : (game == 2)? led_peak2: (game == 3)? led_bomb : (game == 4)? led_power: led_game0;
assign an = (game == 1)? (!sw[0])? an_game1 : 4'b1111 : (game == 2)? an_game2 : (game == 3)? an_game3 : (game == 4)? an_game4 : an_game0;
assign seg = (game == 1)? seg_game1 : (game == 2)? seg_game2 : (game == 3)? seg_game3 : (game == 4)? seg_game4 : seg_game0;

endmodule


