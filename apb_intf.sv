interface apb_intf(input bit pclk,presetn);


logic [31:0]paddr  ;
logic       penable;
logic       psel   ;
logic       pready ;
logic       pwrite ;
logic [31:0]pwdata ;
logic [31:0]prdata ;
logic       pslverr;


clocking drv_cb @(posedge pclk or presetn);
	default input #1 output #1;
	output  paddr  ;  	
        output  penable;
        output  psel   ;
        input   pready ;
        output  pwrite ;
        output  pwdata ;
        input   prdata ;
        input   pslverr;
endclocking
	


clocking mon_cb @(posedge pclk or presetn);
	default input #1 output #1;
	input  paddr  ;  
        input  penable;
        input  psel   ;
        input  pready ;
        input  pwrite ;
        input  pwdata ;
        input  prdata ;
        input  pslverr;
endclocking


modport driver(clocking drv_cb,input pclk,input presetn);

modport monitor(clocking mon_cb,input pclk,input presetn);


//-----------assertions

//penable asserted after 1 clk cycle of psel
  property enable_h;
	  @(drv_cb) $rose(psel) |=> penable;
  endproperty

//stable during penable assertion
  property stable_h;
	  @(drv_cb) $rose(penable)|-> $stable(paddr) ##0 $stable(pwdata) ##0 $stable(pwrite) ##0 $stable(psel);
  endproperty

//penable deaasert after pready high
  property de_penable_h;
	 @(drv_cb) penable && psel && pready |=> $fell(penable);
 endproperty

assert property(enable_h)
  `uvm_info("intf","enable asserted after 1 clk cycle of psel",UVM_DEBUG)
  else
   `uvm_error("intf","enable not asserted after 1clk cycle of psel")

assert property (stable_h) 
            `uvm_info("intf", "stable signals during penable", UVM_DEBUG)
        else
            `uvm_error("intf", "signals not stable during penable")
    
        assert property (de_penable_h) 
            `uvm_info("intf", "penable deasserted after 1 clk of pready", UVM_DEBUG)
        else
            `uvm_error("intf", "penable not deasserted after 1 clk of pready")


endinterface
