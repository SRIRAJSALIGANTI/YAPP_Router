/*-----------------------------------------------------------------
File name     : yapp_router.v
Developers    : Kathleen Meade, Brian Dickinson
Created       : 23 Jun 2009
Description   : YAPP Router RTL model
Notes         : New version properly drops packets with extra debug reporting
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

//****                                                                ****
//****                         waveforms                              ****
//****                                                                ****
//
//                _   _   _   _   _   _   _   _   _   _   _   _   _   _   
//clock ...... : | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_ 
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                ___________________             _______________
//in_data_vld  : /                   \___________/               \___________
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   
//                                        ___                         ___
//error....... : ________________________/   \_______________________/   \___
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                ___ ___ __...__ ___ ___         ___ ___ __...__ ___
//in_data .... : X_H_X_D_X__...__X_D_X_P_>_______<_H_X_D_X__...__X_P_>_______
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//                _______________________         ___________________
//packet ..... : <______packet_0_________>-------<______packet_1_____>-------
//               :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
//
//H = Header
//D = Data
//P = Parity
// 
// the router assert data_vld_x  when valid data appears in channel queue x
// assert input read_enb_x to read packets from the queue.
// receiver must keep track of packet extent and size.
// error is asserted if parity error is detected at the end of packet reception 
//
//****************************************************************************/
`timescale 1ns/100ps 

  module host_ctl (input clock,
              input reset,
              input wr_rd,
              input en,
              input [7:0] addr,
              inout [7:0] data,
              output en_out,
              output [7:0] max_pkt_size_out);

   parameter   DEF_MAX_PKT = 8'h3F;
   parameter   DEF_EN = 1'b1;
   //parameter   DEF_EN = 1'b0;   //KAM - For Training
    `pragma protect begin_protected
`pragma protect version = 1
`pragma protect author = "IP Provider" , author_info = "Widget 5 version 3.2"
`pragma protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "10.6c"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
FfHUgIsfLHkqh/2RuoYHn6dW9S71xHaibuR2U4zUtIFE1nicGdmKgFp69INI5KCl
RDXId1TbvJ901uZwvAmyeXHsXzrsErgoN4rxCCCl7xEuvc11uGw6uztiPNNXxgDq
TLe8yhwXQw7hsBYFbEnOu/wkQ3OLxEy6iOJcW1UbjWVF523kKye9cDS4k8fD94sg
RMRUnOOxB5QCrLgYZtGUimOZeVZrYi8DaeSBYcXHiODVxV21R6+Fi1Z06Ur91uCV
ahOtfjAiSwzo4j+xvFgyaBhMyBsCJxbc8b4kVbfgs4vjTdacRbAQWZFz3+ltXDKy
TODsLt6oK+uU05LCl5nr7g==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 1152 )
`pragma protect data_block
gv0dsVfFijtg1pwLsM8SwtzCOtIu1zklX+caROadbhC7yi1NN+Al8FavdxYl1Th8
bd9gZXv+xo1LyO+lfvgqOn92Loo5u2G5kiISUd1+7NwVWrZowxZkAvvXb1WZtSkv
STw5DpY/v4TbQJNSEjMsV6OYr+q2Cg05OgaPuwfl95ykyU1kjT4Lg7myELhOtnSD
8klNw3i67ZY3eX465clW//XJoKGqmieNr4KDt2B5os/IH3tsp9ehh8UUVO/hjvAP
oP+nnepvQDionwCN7Hb9ZYdk0m3pKsKEPRVbgJcgxa9+PS0bRFKEiEDH8Gi0KS2o
4DE9B3tTU74vdsDSZABnfv3SN0LEUeGOPhHU9gN4V8BPzal1MLQFjAv8I31tKPld
vL2YPSl0RFsLAY3UE6Tjt2ipOx+bm32qzcpDcyaMwU4pZoKmCR2obNpqLXrxe5yP
gpmnSFJjo1SKxxVkMA0fnVCy1XPTOoUfaR9cOTDMN5yflz5BKJSVSqIkSS7N1rbW
jl4EkZSU4m77C/QbWZ2jMbWcss0y8JGF4R0+tt1u5bI+YuUKnluQmOyAsDK5moWk
73m8hHd2gyk/2zJuqtKVEZ+QtryjJlvo+s0vxOR7TV8KpFR5sS2aXSHQUmyVUZYP
aoxnAzoKvssZCPgzFA/J6ryZXCVOEZgNjap7WNTU9xUZNu74Jrc6AvCmZwYqTwjO
tgcyN0J5BlxBuEILXpYrI0Pcrm2HiiMek8OqsKH7WmuIkxYzHriblOeVxe3xveBw
6HjzzB1XI6i4DG/6O+kT1lg/RAbVPFvoLB5uT3HSaoD11KgMSM1xzV+HYChfeJ7m
vFY4uGwpreIG6nExyzQ4fgPRPJK94Iqf+xRBj1VVT88syIuyQvNu48c3iG17Zh2y
8H45dRLft8E8UGoxKfxx89BXCKnzzEIRkpO4JrI8qYbII2BkB4eTFU/BRKjEEnHQ
utnTnvE4e6VTOpoyBANt4voGdjrgpPmB1wEU8QmzC93ITurO5KgUZ0egAp4Wq33H
lqYCU41s5BOS/+zXhzgLmVSh+Enr3RSmgl80hxGhWGaRUPa/zhYduWDqJiIkl5yY
zE+I5YFP89GstP73I02ZWsqspbY3+kqWAt2vqVXwwFfUinAtu/CjsK1GCSPz9/4X
yx4YvccUm89cfqkVH0Nj1lD6BkTHD6t4rBoXp8b5XG9EstXfIRMS46eG+LdPo4Qm
ve7NCDLSJE0En81j3ER4w8IHKvTfnLmKu+t/q02sglOaDoj4ykcOFSuZTSuI+m//
xSb5dozr0WnwxnaapSd55QsQkAj6iWaHQGfAJtAgzB8Nkurp5rg6bcYj/VFPz54b
GZQmVQ+G/y5toA76x/tci8WwbDZxqTJyU3dnPLi+QC9xyxaMj0P3cL1arYHf7RuY
iWav9wKe3T5SuT+C0kuJ0SB+NhfnOgdfj9nAoplxhUdyee9f1aRUwSH6JOlDi9U3
ldmwkyCRYqyZx45RZt87KBMGtn+N1guuGj/nGYkzs3y1UNh+7ATvVtaUaHFG8Jal
`pragma protect end_protected
endmodule // host_ctl
   
module fifo (input clock,   
             input reset,
             input write_enb, 
             input read_enb,  
             input [7:0] in_data,  
             output reg [7:0] data_out,  
             output empty,   
             output almost_empty,   
             output full);


    `pragma protect begin_protected
`pragma protect version = 1
`pragma protect author = "IP Provider" , author_info = "Widget 5 version 3.2"
`pragma protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "10.6c"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
bHtN+YzmsmLqovdmCqEoYNPjpdC23IzJik4zrgpvA6+rHdN61Q5mxDbMQ+TexWjb
AhyfhZ684S9bIIqF7jCN1Tgy1BEvD0dPQNTYcPEDqkTaiTd0jHCDctenXRaz4gJF
OGUByqs6KOPnS6Z8Slpc5sYWt7GuwvUtVovCOOBi5A5Wkjm+XzjctWwhbKnd6aEr
e4/zQhpXwZ6J/Yslr2KKKEh6jnxTBG6ue2KsAlLuNLHO5ZxO4aeUxlCytYkQeXl+
mpS7dGAdC+rU+KaCTvCBQR5RVYWeQZHBnzTXdwbPIMvfFcjpHXTWTIPi6LSFJsX7
fS5e4BNhsmkngZH/SlWyRQ==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 1936 )
`pragma protect data_block
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
L1SfQFBn8AhPwr8KG3ky1Q==
`pragma protect end_protected
endmodule //fifo

//****************************************************************************/

`define HEADER_WAIT  2'b00
`define DATA_LOAD    2'b01
`define DUMP_PKT     2'b10

module port_fsm (//FSM Control Signals
                 input clock,       
                 input reset,
                 input hold,        
                 input fifo_empty,    
                 output reg   error,

                 // Host Interface Registers
                 input router_enable,
                 input [7:0] max_pkt_size,

                 // Input Port Data
                 input  [7:0] in_data,      
                 input  in_data_vld,    
                 output in_suspend, 

                 // Output Port Data
                 output     [1:0] addr,
                 output     [7:0] chan_data,
                 output     [2:0] write_enb);    
 
    `pragma protect begin_protected
`pragma protect version = 1
`pragma protect author = "IP Provider" , author_info = "Widget 5 version 3.2"
`pragma protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "10.6c"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
n2emSj/qZFfHLp2Ik7Ir8sQu2908kzCMqrVO8omoQAl/gMwzlOuF+vSZHSXJwpPq
9XxgfNtt/fF3GfXJC1e+m5TDMZP+EVdlybDA/LAMzcXiZ9Ge5mp/fFUdlKgiBENp
F9AAYyoMBeEABQzu4/uNHtvdtvcq6WRFxQVmceTvSt3kdwhr6ITTtbywe8shOYf/
CyU6uxftsZkn8WytcaQL7433FFEHw6/eJX3QoN4IQ7dxcTYon+BHSBVK8191/Mf6
iH4sVXGt6pG6BAjEFT3uuAu37nRpwla+0c41/C9xQaYztWHezHHsgy94q/2nacWq
5HYXn1L+ZbUHMKOZpWVDlg==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 3968 )
`pragma protect data_block
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
`pragma protect end_protected
endmodule //port_fsm

//****************************************************************************/

module yapp_router (input clock,                              
                    input reset,                            
                    output error,

                    // Input channel
                    input [7:0] in_data,                           
                    input in_data_vld,                     
                    output in_suspend,

                    // Output Channels
                    output [7:0] data_0,  //Channel 0
                    output reg data_vld_0, 
                    input suspend_0, 
                    output [7:0] data_1,  //Channel 1
                    output reg data_vld_1, 
                    input suspend_1, 
                    output [7:0] data_2,  //Channel 2
                    output reg data_vld_2,
                    input suspend_2,
     
                    // Host Interface Signals
                    input [7:0] haddr,
                    inout [7:0] hdata,
                    input hen,
                    input hwr_rd);                            


    `pragma protect begin_protected
`pragma protect version = 1
`pragma protect author = "IP Provider" , author_info = "Widget 5 version 3.2"
`pragma protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "10.6c"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
NnEc7/nx17skcOlfoVPbKamc+d42ytSDPYwb3lRzt+v0wyKb0BC4CszWO4CDoWWg
jphxNvE9PgdYb2suPV4DPTdL4lTvejmkv7iQlFZQY4Xq80d4zQgFoXgoJz3thW4z
t6YHx54wyIWYiac3NBy4/Wg0fPu7Z1eGJ4ds8UcShBpXntDiyD+OvNLmQ1NGXRhR
A1iCQXDMrwjx9tjUuYxy9+NKCPWlwug9LMUVs+zWR7N2Hq/X14fXIIORkFGARCAU
ZfAH12BGy97q+rkhaNOkfR8uajeU203Z9I43u65O2dXEkmrpqSZAyFJgP4dWj3Qb
AvpWFqOJ/EgiwFOQQNA5lA==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 3552 )
`pragma protect data_block
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
`pragma protect end_protected
endmodule //yapp_router
