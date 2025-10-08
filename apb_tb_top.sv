module apb_tb_top;
//global signals
bit pclk;
bit presetn;

always #5 pclk=~pclk;

initial begin
   #5 presetn =0;
   presetn=1;
end

//interface calling

apb_intf intf(pclk,presetn);

//dut connection
//
apb_dut uut
(
	.pclk   (pclk        ),	
        .presetn(presetn     ),
        .paddr  (intf.paddr  ),
        .penable(intf.penable),
        .psel   (intf.psel   ),
        .pready (intf.pready ),
        .pwrite (intf.pwrite ),
        .pwdata (intf.pwdata ),
        .prdata (intf.prdata ),
        .pslverr(intf.pslverr)
);

//virtual interface set 

initial begin
	uvm_config_db#(virtual apb_intf)::set(uvm_root::get(),"*","vif",intf);
end

//run_test calling ( includes the termination code internally in library)

initial begin
	run_test("wr_rd_test");
end

endmodule
