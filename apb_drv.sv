class apb_drv extends uvm_driver#(apb_seq_item);
`uvm_component_utils(apb_drv);

apb_seq_item tx;
virtual apb_intf drv_intf;

function new(string name="apb_drv",uvm_component parent);
	super.new(name,parent);
endfunction

//build_phase

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
       if(!uvm_config_db#(virtual apb_intf)::get(this,"","vif",drv_intf))begin
	 `uvm_fatal("drv","no drv vif found");
	     end
endfunction

task run_phase(uvm_phase phase);
       forever begin
	     @(posedge drv_intf.pclk or drv_intf.presetn);
	     tx=apb_seq_item::type_id::create("tx");
	     seq_item_port.get_next_item(tx);
	     driver_logic(tx);
	     seq_item_port.item_done();
     end
endtask

task driver_logic(apb_seq_item tx);
	$display("[%0t] DRIVER: Received operation = %s", $time, tx.op.name());
	if(tx.op==write) begin
		write_w(tx);
	end
	else if(tx.op==read)begin
		read_r(tx);
	end
	else if(tx.op==wr_rd)begin
		wr_rd(tx);
	end
endtask

task write_w(apb_seq_item tx);
	$display("[%0t] Driver starting WRITE", $time);
	@(posedge drv_intf.pclk);
	drv_intf.drv_cb.paddr <=tx.paddr;
	drv_intf.drv_cb.pwdata<=tx.pwdata;
	drv_intf.drv_cb.pwrite<=1'b1;
	drv_intf.drv_cb.psel  <=1'b1;
	$display("[%0t] WRITE setup phase complete", $time);
   
//asserting penable after the stable signals

	@(posedge drv_intf.pclk);
        drv_intf.drv_cb.penable <=1'b1;
        $display("[%0t] WRITE access phase", $time);	

//a block to wait for pready to be high

	while(!drv_intf.drv_cb.pready)begin
		@(posedge drv_intf.pclk);
		drv_intf.drv_cb.psel   <=1'b1;
		drv_intf.drv_cb.penable<=1'b1;
         $display("bfm still waiting");
 	end
	$display("[%0t] pready received", $time);
//deassertions after the completion
	@(posedge drv_intf.pclk);
	drv_intf.drv_cb.penable <= 1'b0;
        drv_intf.drv_cb.psel    <= 1'b0;
    	drv_intf.drv_cb.paddr   <= 32'h0;
    	drv_intf.drv_cb.pwdata  <= 32'h0;
    	drv_intf.drv_cb.pwrite  <= 1'b0;
        $display("[%0t] COMPLETE: Write transaction finished for addr 0x%h", $time, tx.paddr);
endtask

task read_r(apb_seq_item tx);
	$display("[%0t] Driver starting READ", $time);
	
	@(posedge drv_intf.pclk);
	drv_intf.drv_cb.paddr  <= tx.paddr; 
	drv_intf.drv_cb.pwrite <= 1'b0;        
	drv_intf.drv_cb.psel   <= 1'b1;      
	drv_intf.drv_cb.penable<= 1'b0;      
        $display("[%0t] READ SETUP phase complete",$time); 

//penable asserted after stable signals

        @(posedge drv_intf.pclk);
        drv_intf.drv_cb.penable <= 1'b1; 
        $display("[%0t] READ ACCESS phase", $time);

	#0;
	if(drv_intf.drv_cb.pready)begin 
	
		tx.prdata=drv_intf.drv_cb.prdata; 
		$display("[%0t] READ complete, captured data = 0x%h", $time, tx.prdata);
	end else begin
		do begin
			@(posedge drv_intf.pclk);
			drv_intf.drv_cb.psel   <= 1'b1; 
			drv_intf.drv_cb.penable<= 1'b1; 
			$display("[%0t] Still waiting for pready...", $time);
		end while (!drv_intf.drv_cb.pready); 
		tx.prdata=drv_intf.drv_cb.prdata;    
		$display("[%0t] READ complete after wait, data = 0x%h", $time, tx.prdata);
	end
//deassertion of signals
	@(posedge drv_intf.pclk);
        drv_intf.drv_cb.penable <= 1'b0;  
        drv_intf.drv_cb.psel    <= 1'b0;  
        drv_intf.drv_cb.paddr   <= 32'h0; 
        drv_intf.drv_cb.pwrite  <= 1'b0;  
	$display("[%0t] COMPLETE: Read transaction finished", $time);
endtask


task wr_rd(apb_seq_item tx);
	bit [31:0] saved_addr = tx.paddr;
	bit [31:0] saved_data = tx.pwdata;
	
	write_w(tx);		//write calling
	tx.paddr = saved_addr;	// to save address from write and use it to read
	read_r(tx);		//read calling
	
	if (tx.prdata !== saved_data) begin
		$display("[%0t]  WR_RD MISMATCH: wrote=0x%h, read=0x%h", $time, saved_data, tx.prdata);
	end else begin
		$display("[%0t]  WR_RD SUCCESS: data=0x%h", $time, tx.prdata);
	end
endtask
endclass

