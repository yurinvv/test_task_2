class BaseTest;
	Environment environment0;
	
	int stimuli_array [$];
	
	string ref_extrinsic_path;
	string ref_llr_path;
	string stimuli_path;
	string test_name;
	

	function void readStimuli();
		
		int fd = $fopen(stimuli_path, "r");
		string line;
		int j = 0;
	
		while(!$feof(fd)) begin
			$fgets(line, fd);
			
			if (line == "")
				break;
			
			stimuli_array.push_front(line.atoi());
			j++;
			//$display("BaseTest: %d) stimul value = %d", j, line.atoi());
			
		end
		$fclose(fd);
		
	endfunction
	
	function new();
		environment0 = new;
	endfunction
	
	task run();
		readStimuli();
		environment0.driver0.array = this.stimuli_array;
		environment0.scoreboard0.ref_extrinsic_path = this.ref_extrinsic_path;
		environment0.scoreboard0.ref_llr_path = this.ref_llr_path;
		
		$display("T=%0t Test %s is starting...", $time, test_name);
		environment0.run();
	endtask

endclass