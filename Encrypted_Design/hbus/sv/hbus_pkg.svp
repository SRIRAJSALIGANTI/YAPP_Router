/*-----------------------------------------------------------------
File name     : hbus_pkg.sv
Description   :
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`ifndef HBUS_PKG_SV
`define HBUS_PKG_SV

package hbus_pkg;

 import uvm_pkg::*;
 `include "uvm_macros.svh"

/*-----------------------------------------------------------------
File name     : hbus.svh
Description   :
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`ifndef HBUS_SVH
`define HBUS_SVH

typedef uvm_config_db#(virtual hbus_if) hbus_vif_config;

`include "hbus_transaction.sv"
///monitor_start
//
/*-----------------------------------------------------------------
File name     : hbus_monitor.sv
Developers    : Kathleen Meade
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`ifndef HBUS_MONITOR_SV
`define HBUS_MONITOR_SV

//------------------------------------------------------------------------------
//
// CLASS: hbus_monitor
//
//------------------------------------------------------------------------------

class hbus_monitor extends uvm_monitor;

  // This property is the virtual interfaced needed for this component to drive 
  // and view HDL signals. 
  virtual hbus_if vif;

  // The following two bits are used to control whether checks and coverage are
  // done both in the monitor class and the interface.
  bit checks_enable = 1;
  bit coverage_enable = 1;

  // This port is used to connect the monitor to the scoreboard
  uvm_analysis_port #(hbus_transaction) item_collected_port;

  //  Current monitored transaction  
  protected hbus_transaction transaction_collected;

  // Count Reads/Writes for summary report at end of simulation
  int num_read_trans, num_write_trans;

  // Events needed to trigger covergroups
  //CHANGE TO .sample(): event cov_transaction;

  // transaction collected covergroup
  //covergroup cover_transaction @cov_transaction;
  covergroup cover_transaction;
    option.per_instance = 0;
    address : coverpoint transaction_collected.haddr {
          bins max_pkt_reg = {0};
          bins enable_reg  = {1};
          bins other_regs  = {[2:31]}; 
          //bins ignore    = {[32:$]}; }
          bins ignore    = default; }
    direction : coverpoint transaction_collected.hwr_rd;
    addressXdirection : cross address, direction;
  endgroup : cover_transaction
  
  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(hbus_monitor)
    `uvm_field_int(checks_enable, UVM_ALL_ON)
    `uvm_field_int(coverage_enable, UVM_ALL_ON)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
    void'(get_config_int("coverage_enable", coverage_enable));
    if (coverage_enable) begin
      cover_transaction = new();
      cover_transaction.set_inst_name({get_full_name(), ".cover_transaction"});
    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!hbus_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  // run_phase
  virtual task run_phase(uvm_phase phase);
    fork
      collect_transactions();
    join
  endtask : run_phase

  // Collect transactions
  virtual protected task collect_transactions();
   // Create Transaction
   transaction_collected = hbus_transaction::type_id::create("transaction_collected", this);
   forever begin 
    fork  
    begin
       @(posedge vif.reset)  // Wait on Reset
          `uvm_info(get_type_name(), "Reset Active", UVM_MEDIUM)
       wait (!vif.reset) // After Reset
       `uvm_info(get_type_name(), "Reset Deasserted", UVM_MEDIUM)
    end
    begin
    wait (!vif.reset) // After Reset
      //@(posedge vif.clock iff vif.hen) 
      @(posedge vif.hen)
    `pragma protect begin_protected
`pragma protect version = 1
`pragma protect author = "IP Provider" , author_info = "Widget 5 v3.2"
`pragma protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "10.6c"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
RgZX+EwGPMa1SS2tuU7VscnayBq3VWuAUFwU9gfJY0HostvLZ5bTY+AocqUVxFiS
fKtGneZkjqURVQJKS/YzPutzcrE4FD1OJI1lDlCkDfzEF2D3pHj2lqeaTxBmrVEG
djHUXiR2fOrKdYWTZ+7imGx8u+iX/L3LPuVO7FAp16VfefaGejgc7c9PTl0nDqxH
2oSoZpkXHEjmI9XY3cHEQcVMpQFUOOFObDX54hgUTBOVUfbUV7985fNiAPspkJfE
XcGAclbGcOdfmZPCtKv3HgQOl4oa/9zfInxtNX5HBu9+dlDYRGZbsrcpduSqKL/p
FgHkwS1jdlmPFEnLloOicA==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 624 )
`pragma protect data_block
zDQDDILsLagzIznfL0dJkbBucKfaa3R5O307/yEmsDtTxlqUgqcQ8m5UFgkqWBpX
QcguBfpeWn3hrUv0eemxPrTf4IFEykEMydb5rc+qeCXnsv/fndjmR4QYRyRzm7Fa
YF6SSalQMpMtq+Q8NEqxnAaY85yNgFqXkod6q2Ir6mqE6EO7PMGic4MgBdtKOZNv
2XlB9EC8GmIPgHix+kiSEkgW8Y3r/OGHNFXrNl2EYWsrukLIk4z028+HhNp7EWr+
0MPcR+U2xq4QLB4LSSnRsn49aZ2PL+BG1NE0rtDzsgWPpF6tWQAFhJm+xdR+pp/H
EuLrC13/C4L23TbkOKy2gFi/gMKtjlaOviZZQkaoJee7uYF78l4l920eAASRU1aU
SjZvFp8Cg8/p7JkVIZDNafG9OkX/i2KHAw7srO0LVJN6/OXd670azk+HlMyTyM7d
oZ/FTQNEf5/CKxFStAI+n+36i2vmUYJBKp1SvIQhswF72dQWyUENiV8vlRSYE4qe
oA9U9jmWfyNioPlshx4niuwUt2+GD1y/6KLx6Fv7W/g6Ztnskl0bc7/Ggbn+augd
m0uxrEU6rRHj4rvDRs5v95RreQ/3TYyCqC+WiCnIexTw9EU7gIIeJ3sWWmoGoV1n
Eq/Mccm5e0DpuyW5PxAQPPHa4HLpFMibv0AXtLZtxC73MyTJSG0mdVK65FXax/FV
DvBTke9qGBwXylKAk/jbCMlcAnQYa2GwMdsWaobzv31E7mDMzBQllGZ17khN3uaN
Q9xgcgg92QFj1XFWvc9ERCiFGsGFtCMlXTgxxXn6QrNm8za26cKv9+XH3qKFu3kJ
`pragma protect end_protected
          transaction_collected.hwr_rd = HBUS_READ;
          @(posedge vif.clock);
          transaction_collected.hdata = vif.hdata_w;
          @(negedge vif.clock);
          num_read_trans++;
        end
        void'(this.end_tr(transaction_collected));
        `uvm_info(get_type_name(), $sformatf("transaction collected :\n%s",transaction_collected.sprint()), UVM_LOW)
      if (checks_enable) perform_checks();
      if (coverage_enable) perform_coverage();
      // Broadcast transaction to the rest of the environment
      item_collected_port.write(transaction_collected);
    end
   join_any
   disable fork;
  end
  endtask : collect_transactions

  // Performs transaction checks
  virtual protected function void perform_checks();
  endfunction : perform_checks

  // Triggers coverage events and fill cover fields
  virtual protected function void perform_coverage();
     //-> cov_transaction;
     cover_transaction.sample();
  endfunction : perform_coverage

  // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: HBUS Monitor Collected %0d WRITE and %0d READ Transactions", num_write_trans, num_read_trans), UVM_LOW)
  endfunction : report_phase

endclass : hbus_monitor

`endif // HBUS_MONITOR_SV
///monitor_end
`include "hbus_master_sequencer.sv"
////driver_start
/*-----------------------------------------------------------------
File name     : hbus_master_driver.sv
Description   :
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`ifndef HBUS_MASTER_DRIVER_SV
`define HBUS_MASTER_DRIVER_SV

//------------------------------------------------------------------------------
//
// CLASS: hbus_master_driver
//
//------------------------------------------------------------------------------

class hbus_master_driver extends uvm_driver #(hbus_transaction);

  // The virtual interface used to drive and view HDL signals.
  virtual hbus_if vif;

  // Master Id
  int master_id;

  // Control signal for the hbus driver
  //      if==0, delay between cycle is fixed to 1
  //      if==1, delay is based on value of wait_between_cycle
  bit random_delay = 0;

  // Provide implmentations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(hbus_master_driver)
    `uvm_field_int(random_delay, UVM_DEFAULT)
    `uvm_field_int(master_id, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!hbus_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  // run_phase
  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // Gets transaction from the sequencer and passes it to the driver.  
  virtual protected task get_and_drive();
    @(negedge vif.reset);
    `uvm_info(get_type_name(),"Reset Dropped", UVM_MEDIUM)
    forever begin
      //@(posedge vif.clock);
      @(negedge vif.clock);
      // Get new item from the sequencer
      seq_item_port.get_next_item(req);
      // Drive the data item
      `uvm_info(get_type_name(), $sformatf("Driving transaction :\n%s",req.sprint()), UVM_MEDIUM)
      drive_transaction(req);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // Reset all master signals
  virtual protected task reset_signals();
    forever begin
      @(posedge vif.reset);
      `uvm_info(get_type_name(),"Reset Observed", UVM_MEDIUM)
      vif.hen     <= 'b0;
      vif.hdata   <= 'hz;
      vif.haddr   <= 'hz;
      vif.hwr_rd  <= 'b0;
    end
  endtask : reset_signals

  // Gets a transaction and drive it into the DUT
  virtual protected task drive_transaction (hbus_transaction transaction);
    `pragma protect begin_protected
`pragma protect version = 1
`pragma protect author = "IP Provider" , author_info = "Widget 5 v3.2"
`pragma protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "10.6c"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
FDoRADvsQUN+zWGmjxz7IpVL/sEjL/31SK144Uz5V2+fUIzdgXPs8JvXjFESjN66
zGjV3TWZIGsDgddnJM4huev+0vHiFERJzUaoB7QgcwtYT5ak4jZlkVTFGn4VTnY6
+ABO0dmj3G6sSELCXEnKRyhBmi2f5H5C7nKnRT5HbLGx1WlbKcyY++h2cY3ZiquL
GPrVJrmNlNWnrCCRCbogiRjh+pqXtvuw7qTbH316sXmbCldnQQPv+RcaxjfeMPjm
2DkIoIk26xoTwJWXHVxYTGNnCAuiiNMGLRSf+llcWeeuzrjQ+hqmr36vV17ewGcW
TrB4aahiSF/VSV8uWXfv0Q==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 1136 )
`pragma protect data_block
pYxOYESr+6VDrqyMdemTrX47topsLc+23XlB85MULGDpjY2cwbSVeKjYWQfuggwd
bU745Z0uKm9n+MeSxUSjMx4/xZ1E5cEeem1tPOGKf4W9ffXK+ZdeLOAaVtVXL/Ii
x/gV7KeWKFQbpp7mTxD6zv9BDed0F8t2roAyXz1eZppeNkZbxZXcY3aCFxYlHaV/
+m2hwNAWZ1fx1XaDwLvGAbcwT1pE92hUnPfuVnjcQuEDIAOb60z/oIQiCBb1tlwY
aoAUG7PWa174rkM6UD3lKCa6sgCFAVIyHH3QSm/OZmdlbz9+OeRWTOaXUcyYxtT6
cFMuQGj1Aem4o9/8vWKfIftv3yS/8KtD0btVV8UUIRQZLn1KsJUGVTdspJdWOEYn
MXPFohHE0YjoL904ANQ6wCLsCVz1HhIbonIpUvgSXWUSIlfSiilriqcj6WMmFbVU
eZZDxyNb4IRCLlDQ0DWIxhZwPpUGntDtBN563gAvI5L1lV9Xnq/osgNPU+BKFNuJ
X+FhavliDieeXcPcL6Dxri0oFBM4GYb4lnjoV0LvWpfRCWpjNBITGsB71R30zQAb
MABz3EDHDH+qIBVwISxP+EEckcXHbJMldfpG/Y5EnBRBkC95UDy3kdaIxj2AtSfh
Ju55sdNWYKdqLgLaHZT6TIsp0sW84IbkIhBd181c2sgELRdaDzXJpYR64F3XfjkA
fEI+tIgXvIU3NF4PqWn+MUQ/j5N6YgPE60q0H60KdLWXce8VjdUZaLr9EKcZAp+x
zMjeBZAyA9PWu3ATZ3jdNqbbIYlIaLoJVnQJ3eDdStO/EaCMjaWZTu97upINZIzI
Iq6rx+XJ+i6ZTf/k5Bfv/tfyBQXkJUR07JWIAAuRaacZyrOXCLS2Ggsf2CUeMFO6
Rer3WoEVUWLP1S3ECylO3flTLx8nqi0/5uK6onzjxajdtJRhKjZCsfDnPsx5/AKP
y/9HM9jXLh6Y+QiEMXM6AOMqg8pgRHaFbov49GR8oKP41V92yYIdLjsHz+vAXh3k
Kfod2NLQn/zItyuEljX4LT16BQMjGzFbUN2ACjoYZMQ1VOUovH48sH9yj8mV8FQs
HsihPlNOfwHOC6CIdpu2HbUryTr1Jr30Zz5yfY+Vt60r3Nibn15n7fHeRQS86YWA
eXUtfzzjqvcFy0suB9kFjLyHOryBns8vUkRRkyCtp4XrBjqcVDlvKS6Z82yb7Vp1
LGt0fgnVmhFAp7XgwWUEsuXXyMyyDgQUgBWCE27FgfcequKN+CA2rM9ePRnluvCI
bnpDPbLF8HQX7sPAkCy9FXE+2Ivj6QGkMUNfXGg6+UO0+J8e1lIUsk6WUpRKCV2Y
dDhYPV/JMaivHyRyVHsJKSj6WhSCu7oykfmJ+Sa9cPkoUxwDN3b2n9QaJQLCejt6
jKofCFGVJk/s2joy7hOzkkpzzcFIohFtAnToFClHDMgg4d5/jbbhhdGcGgiqfAqh
SWl8/gHOkJGDH91S0GX7ySmrk3pvRZ3X8CsqKZTxuVk=
`pragma protect end_protected
endclass : hbus_master_driver

`endif // HBUS_MASTER_DRIVER_SV




///driver_end
`include "hbus_master_agent.sv"
`include "hbus_master_seqs.sv"

`include "hbus_slave_sequencer.sv"
///slave_driver_start
//
/*-----------------------------------------------------------------
File name     : hbus_slave_driver.sv
Description   :
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`ifndef HBUS_SLAVE_DRIVER_SV
`define HBUS_SLAVE_DRIVER_SV

//------------------------------------------------------------------------------
//
// CLASS: hbus_slave_driver
//
//------------------------------------------------------------------------------
 
class hbus_slave_driver extends uvm_driver #(hbus_transaction);

  // The virtual interface used to drive and view HDL signals.
  virtual hbus_if vif;

  bit [7:0] max_pktsize_reg = 8'h3F;
  bit [7:0] router_enable_reg = 1'b1;
  bit [7:0] hbus_memory [32];

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(hbus_slave_driver)
     `uvm_field_int(max_pktsize_reg, UVM_DEFAULT)
     `uvm_field_int(router_enable_reg, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!hbus_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  // UVM run_phase
  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // Continually gets responses from the sequencer
  // and passes them to the driver.
  virtual protected task get_and_drive();
    @(negedge vif.reset);
    `uvm_info(get_type_name(),"Reset Dropped", UVM_MEDIUM)
    forever begin
      @(posedge vif.clock);
      // Get new item from the sequencer
      seq_item_port.get_next_item(rsp);
      // Drive the response
      send_response(rsp);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // Reset all slave signals
  virtual protected task reset_signals();
    forever begin
      @(posedge vif.reset);
      `uvm_info(get_type_name(),"Reset Observed", UVM_MEDIUM)
      vif.hdata      <= 'z;
      max_pktsize_reg = 8'h3F;
      router_enable_reg = 1'b1;
    end
  endtask : reset_signals

  // Get response and drive it into the DUT
  virtual protected task send_response(hbus_transaction resp);
       `pragma protect begin_protected
`pragma protect version = 1
`pragma protect author = "IP Provider" , author_info = "Widget 5 v3.2"
`pragma protect encrypt_agent = "QuestaSim" , encrypt_agent_info = "10.6c"
`pragma protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`pragma protect key_block
kRL0kv3js0CuigENfb8ZsPm8/0ZNW7r+vWBLjz45fvDRALiqkcnWv1rJvOrGSleh
yhJ5Mk9hDFPUseUNG9XJNx+m2pBUuAPQ7Fj+aCnvkRQDcQK4uMv5BGg0Pyuy93cy
AcB7SZJxlpp0Sufy6XU+x+1qlFBvVtIMpNrG5mSXl9REjp4hE9bRkriItO5X9Dw7
cmhWu4BQhW4gRBhwy25Ayb2CAWBM7teW4hcf+6iCPyXULkkv/xqOlTf3m7aNbie6
MY3OKAV1b+wfBIUEtXJXGzX6UzhtXbKkrkedmNJ5RGPPuDeOLqqugWi0Mgz3fDTf
Ou3LbjQtPXjiOadjNae2Uw==
`pragma protect data_method = "aes128-cbc"
`pragma protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 1312 )
`pragma protect data_block
uGjWx2URzLvcO5GNkw3CqDeP4co+UEm+JQ9e0g46c75yoCRpNB5I30EzGdSkt/Td
c12JIVJchhOuplTsrjdRlwENtjNiR2oLSfzjX6PDZCPSn+58mKtBRWBYxfEC61oW
0KXgoue3fiyV4KpBZ6M0aknraOE0FKwNoPYbQI62HVwhEgOGg7eRLaSKAG9g2LTh
0i40bRvhixBNZp5xCwFLb3uHa2sXwL99fX92XEZenrblAYVdJ+axzu2Dr5hxh5/V
B6tcqXfyG8efxbC9lYSiKUhsB97kHTTMYyxifH+J8cgfajYPS+RVoZarILFKMLvh
Z620v+n5nKEHqo7qnZi0cHMTTRCqXMrGu7wk5bAnqxMIlorC5MCPiFKBYrd8f8Pn
zUI1Ciw9UXIfgBiWdNsP8iucSL75krjP9hCpcM95offKYri+a96Bc2wufJCoXi9R
MwB+V4aTkm27g879tn07fNSHXS3+JzpqKO9/2OYAliaP/ekIAKTeAy9FZxPd4E8W
4dbgZhKf7FUj7eLdNubB1Y8hdsMGFN0Pi6IG3DkSB9BGGJJZ5IQF5Csi1uc5UF6Q
rRZeqIBsk7tXHdQI/4iJvoKxTb7atTG2WAaffnt7fdNt4OgXoN5pCypCBdKSLoF8
1k2UCNJbDefzvqswknISYH5hGP5gOzWlWyCGwFBVhCtYty25JQeKKolMy6vs/f5F
vHuPb7HUS8sUX7eEcH0691bUdAILAK8ZQ6LqXeYsq4j5qsRnm7VzIhMIHssmQKzx
aFihtoDNIh9cRh6R3U96bXJqtLaRWhQsdrgb1uuyUWqfZxAgXIAJtVDwA083rReo
u3oo13eOcom35tAF9d8LVHJ64exiNcf416HvuBIJ56hhL3+UzFeY737VuIAUx7Uj
8Nov5ZCC8Vvvm82EgKo9ITR4PKcUl2Vz3S/zuJ2vk+2Hl6BGvr3DlTHjCdIbXVdc
U/lqFCCwtCT09kURL1jvVU9vNX7iGa82ptjKvz/YPWxhH9exv/zgngUXa8olSJPN
w82/3o+Do8gfa3PhbEbS3KUyl8LSmRuwDQeCSengakymD9Ww7Cp+0BrmeL6Suxsg
tKHgHN200XnkBQ6t3Ab26uWzZD9td0Idq1SB+fX0WUCFywz4TkEnnZ8e3qPsqFhO
svApbu1yLcFCNxxf2iukj/A7a67B1z03PGzXvlZNSO4cTY+shIYy1lTbaNv9cRId
mTyQQzA9K1TCSGNSot7cfRqD92l+umZG+cO5d+rmt70htGdAoFHU2kw+4VkyfeBg
+i9Ih0j0V7Y0kVSGkoty1fwwniGwLX2Kky/VSCasrigRlWShb3Q8ehD15RnD2FYA
ZQubpCNWloEnr54/LdXkXXW00U0CZG3NKDQ4v3ey4d56FSoWm3qPgynWC0X3gaFR
e2x+9MLNUveOjZgDs1hcebMhBRh9o+DprtwoENJSPpYf75pZqo6GYYLy2MPegYk7
aR81QTYfA9fcPiz0HgQlhRogpSVafRCbLW6OgN34wP2Z+DoaTlk8u8OPBHRdjnAK
cnJr7Oe+DaBQeBbtJH/McjpSViP2masS61b0hl5MRVtROHXFZSwBQa5SNyTqP0ze
G9B0JZps3Cb/Wirl60+/1c4juQAnv7U3jLOaIpKZK+KfjrlkBR2aF5dDdjU7Fjny
BzGJFY8/yz5xYO0TAfaWFb2cqeX6WQaV2QKYF/uHBdkxp3lnbLDH4oVtruiOPYrL
o2cKxjNZuh8WP7qH7DgP0w==
`pragma protect end_protected
        endcase
        @(negedge vif.clock);
      end
      `uvm_info(get_type_name(), $sformatf("Response Sent:\n%s",resp.sprint()), UVM_MEDIUM)
      this.end_tr(resp);
  endtask : send_response

endclass : hbus_slave_driver

`endif // HBUS_SLAVE_DRIVER_SV
///slave_driver_end
`include "hbus_slave_agent.sv"
`include "hbus_slave_seqs.sv"

`include "hbus_env.sv"

`endif // HBUS_SVH

endpackage : hbus_pkg

`endif // HBUS_PKG_SV
