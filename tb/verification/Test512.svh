class Test512 extends BaseTest;

	function new();
		ref_extrinsic_path = "./extrinsic_512.txt";
		ref_llr_path       = "./LLR_512.txt";
		stimuli_path       = "./in_512.txt";
		test_name          = "512";
	endfunction

endclass