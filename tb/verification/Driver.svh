class Driver;
	virtual dut_if _if;
	//event driver_done;
	
	//int array[];
	int array [$];
		
	task run();
		$display("T=%0t Driver is starting...", $time);
		_if.initSlaveSignals();
		
		while (array.size() < 0) begin
			@(posedge _if.aclk);
			_if.sendData(array.pop_back());
		end
		
	
		$display("T=%0t Driver sent data and stopped", $time);
		//->driver_done;
	endtask
	
	function void setArray (int array[]);
		this.array = array;
	endfunction
	
endclass