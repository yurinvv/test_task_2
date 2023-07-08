class Monitor;
	virtual dut_if _if;
	mailbox _mailbox;
	
	OutData item;
	
	
	task run();
		$display("T=%0t Monitor is starting...", $time);
		item = new;
		item.sof = 0;
		item.llr_data = 0;
		item.extr_data = 0;
		item.eof = 0;
	
		while( item.eof == 0) begin
			_if.receiveData(item.sof, item.llr_data, item.extr_data, item.eof);
			_mailbox.put(item);
		end
		
		$display("T=%0t Monitor stopped", $time);
	endtask
	
endclass