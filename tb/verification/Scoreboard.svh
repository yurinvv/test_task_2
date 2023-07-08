class Scoreboard;
	mailbox _mailbox;
	
	string ref_extrinsic_path;
	string ref_llr_path;
	
	local integer extrinsic_fails;
	local integer llr_fails;
    local integer check_counter;
    local OutData item;
    int ref_extrinsic_array [$];
    int ref_llr_array [$];
	int ref_llr;
	int ref_extrinsic;

	//////////////////////////////////////////////	
	// Private
	
	/**
	* Method for a loading patterns
	*/
	local function void loadPatterns(string path, ref int array[$] );
		int fd;
		string line;
		string tmp_str;
		
		int start_index = 0;
		int end_index = 0;
		
		int j = 0;
	
		if (path != null) begin
			
			// Read file
			fd = $fopen(path, "r");
			$fgets(line, fd);
			$fclose(fd);
			
			
			// Fill array
			for (int i = 0; i < line.len(); i++) begin
				if (line.getc(i) == ",") begin
					end_index = i - 1;
					tmp_str = line.substr(start_index, end_index);
					//array.push_front(line.substr(start_index, end_index).atoi());
					array.push_front(tmp_str.atoi());
					start_index = i + 1;
					j++;
					$display("Scoreboard: %d) buf value = %d", j, tmp_str);
				end
			end
			
			tmp_str = line.substr(start_index, line.len() - 1);
			array.push_front(tmp_str.atoi());
			j++;
			$display("Scoreboard: %d) buf value = %d", j, tmp_str);
			
		end else 
			$display("Exception for Scoreboard: ref_path == null !!!");
	endfunction
	
	/**
	* Test function. Not for verification
	*/
	/*local function void readAndPrintAllBuf(string path, ref int array[$] );
		int i = 0;
	
		while(array.size() > 0) begin
		    i++;
			$display("Scoreboard: %d) buf value = %d", i, array.pop_back());
		end
		
		$display("Scoreboard: readAndPrintAllBuf ended");
	endfunction*/
	
	//////////////////////////////////////////////	
	// Public
	

	function void setRefExtrinsicPath(string path);
		ref_extrinsic_path = path;
	endfunction
	
	
	function void setRefLlrPath(string path);
		ref_llr_path = path;
	endfunction
	
	
	task run();
		//$display("T=%0t Scoreboard is starting...", $time);
		
		loadPatterns(ref_llr_path, ref_llr_array);
		//loadPatterns(ref_extrinsic_path, ref_extrinsic_array);
		
		//test
		//readAndPrintAllBuf(ref_llr_path, ref_llr_array );
		
		llr_fails = 0;
		extrinsic_fails = 0;
		check_counter = 0;

		while (ref_extrinsic_array.size() > 0 | ref_llr_array.size() > 0) begin
			_mailbox.get(item);
			
			ref_llr = ref_llr_array.pop_back();
			ref_extrinsic = ref_extrinsic_array.pop_back();
			
			if (item.llr_data != ref_llr) 
				llr_fails++;
				
			if (item.extr_data != ref_extrinsic)
				extrinsic_fails++;
				
			check_counter++;
			
			$display("T=%0t Scoreboard. %d) LLR data = %d, reference LLR data = %d", $time, check_counter, item.llr_data, ref_llr);
			$display("T=%0t Scoreboard. %d) Extrinsic data = %d, reference Extrinsic data = %d", $time, check_counter, item.extr_data, ref_extrinsic);
			
		end
		
		//$display("T=%0t Scoreboard stopped", $time);
		$display("T=%0t Scoreboard: Number of Comparissons = %d", $time, check_counter);
		$display("T=%0t Scoreboard: Number of LLR fails = %d", $time, llr_fails);
		$display("T=%0t Scoreboard: Number of Extrinsic fails = %d", $time, extrinsic_fails);
		
		if (llr_fails > 0 | extrinsic_fails > 0) begin
			$display("##################################");
			$display("####     TEST FAILED! :-(   ######");
			$display("##################################");
		end else begin
			$display("######################################");
			$display("####    TEST PASSED!!! :-D      ######");
			$display("######################################");
		end
	endtask
	
	
	
endclass