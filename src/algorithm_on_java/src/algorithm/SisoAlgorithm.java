package algorithm;

import java.util.ArrayList;

public class SisoAlgorithm {

    private final int ALPHA_SIZE = 8;
    private final int BETA_SIZE = 8;
    private final int[] ALPHA_INIT_ARRAY = {0, -128, -128, -128, -128, -128, -128, -128};
    private final int[] BETA_INIT_ARRAY = {0, -128, -128, -128, -128, -128, -128, -128};

    private ArrayList<Integer> in;
    private ArrayList<Integer> sys;
    private ArrayList<Integer> parity;
    private ArrayList<Integer> branch1;
    private ArrayList<Integer> branch2;
    private ArrayList<ArrayList<Integer>> alpha;
    private ArrayList<ArrayList<Integer>> beta;
    private ArrayList<Integer> llr;
    private ArrayList<Float> extrinsic;

    public SisoAlgorithm(ArrayList<Integer> in) {
        this.in = in;
    }

    public void executeAlgorithm() {
        llr = new ArrayList<>();
        extrinsic = new ArrayList<>();

        loadSys();
        loadParity();

        alphaInit();
        betaInit();

        branch1Init();
        branch2Init();

        alphaCalc();
        betaCalc();

        calculateExtrinsic();
    }

    /**
     * Initialize
     */

    private void alphaInit() {
        alpha = new ArrayList<>();

        for (int i = 0; i < ALPHA_SIZE; i++) {
            ArrayList<Integer> rowList = new ArrayList<>();
            rowList.add(ALPHA_INIT_ARRAY[i]); //First element

            for (int j = 1; j < in.size(); j++) {
                rowList.add(0); // Fill other cells by zero
            }

            alpha.add(rowList);
        }
    }

    private void betaInit() {
        beta = new ArrayList<>();
        for (int i = 0; i < BETA_SIZE; i++) {
            ArrayList<Integer> rowList = new ArrayList<>();
            rowList.add(BETA_INIT_ARRAY[i]); //First element

            for (int j = 1; j < in.size(); j++) {
                rowList.add(0); // Fill other cells by zero
            }

            beta.add(rowList);
        }
    }

    private void loadSys() {
        sys = new ArrayList<>();
        for (int i = 0; i < in.size(); i = i + 2) {
            sys.add(in.get(i));
        }
    }


    private void loadParity() {
        parity = new ArrayList<>();
        for (int i = 1; i < in.size(); i = i + 2) {
            parity.add(in.get(i));
        }
    }


    /**
     * Calculate branches
     */
    private int branch1Calc(int sys_item, int parity_item) {
        return -(sys_item + parity_item) / 2;
    }


    private void branch1Init() {
        branch1 = new ArrayList<>();
        for (int i = 0; i < sys.size(); i++) {
            int sysItem = sys.get(i);
            int parityItem = parity.get(i);
            branch1.add(branch1Calc(sysItem, parityItem));
        }
    }


    private int branch2Calc(int sys_item, int parity_item) {
        return -(sys_item - parity_item) / 2;
    }


    private void branch2Init() {
        branch2 = new ArrayList<>();
        for (int i = 0; i < sys.size(); i++) {
            branch2.add(branch1Calc(sys.get(i), parity.get(i)));
        }
    }


    /**
     * Normalization
     *
     * array(:,k) = array(:,k) - array(0,k)
     * array(row, column)
     */
    private void normalize(ArrayList<ArrayList<Integer>> array, int column) {
        for (int row = 0; row < array.size(); row++) {
            array.get(row).set(column, array.get(row).get(column) - array.get(0).get(column));
        }
    }


    /**
     * Calculate alpha
     */
    private void alphaCalc() {
        for (int k = 1; k < in.size(); k++) {
            alpha.get(0).set(k, Math.max(alpha.get(0).get(k-1) + branch1.get(k-1), alpha.get(1).get(k-1) - branch1.get(k-1)));
            alpha.get(1).set(k, Math.max(alpha.get(2).get(k-1) - branch2.get(k-1), alpha.get(1).get(k-1) + branch2.get(k-1)));
            alpha.get(2).set(k, Math.max(alpha.get(4).get(k-1) + branch2.get(k-1), alpha.get(5).get(k-1) - branch2.get(k-1)));
            alpha.get(3).set(k, Math.max(alpha.get(6).get(k-1) - branch1.get(k-1), alpha.get(7).get(k-1) + branch1.get(k-1)));
            alpha.get(4).set(k, Math.max(alpha.get(0).get(k-1) - branch1.get(k-1), alpha.get(1).get(k-1) + branch1.get(k-1)));
            alpha.get(5).set(k, Math.max(alpha.get(2).get(k-1) + branch2.get(k-1), alpha.get(3).get(k-1) - branch2.get(k-1)));
            alpha.get(6).set(k, Math.max(alpha.get(4).get(k-1) - branch2.get(k-1), alpha.get(5).get(k-1) + branch2.get(k-1)));
            alpha.get(7).set(k, Math.max(alpha.get(6).get(k-1) + branch1.get(k-1), alpha.get(7).get(k-1) - branch1.get(k-1)));

            normalize(alpha, k);
        }
    }


    /**
     * Calculate beta
     */
    private void betaCalc() {
        for (int k = beta.size() - 1; k > 0 ; k--) {
            beta.get(0).set(k, Math.max(beta.get(0).get(k+1) + branch1.get(k), beta.get(4).get(k+1) - branch1.get(k)));
            beta.get(1).set(k, Math.max(beta.get(4).get(k+1) - branch1.get(k), beta.get(0).get(k+1) - branch1.get(k)));
            beta.get(2).set(k, Math.max(beta.get(5).get(k+1) + branch2.get(k), beta.get(1).get(k+1) - branch2.get(k)));
            beta.get(3).set(k, Math.max(beta.get(1).get(k+1) + branch2.get(k), beta.get(5).get(k+1) - branch2.get(k)));
            beta.get(4).set(k, Math.max(beta.get(2).get(k+1) + branch2.get(k), beta.get(7).get(k+1) - branch2.get(k)));
            beta.get(5).set(k, Math.max(beta.get(6).get(k+1) + branch2.get(k), beta.get(2).get(k+1) - branch2.get(k)));
            beta.get(6).set(k, Math.max(beta.get(7).get(k+1) + branch1.get(k), beta.get(3).get(k+1) - branch1.get(k)));
            beta.get(7).set(k, Math.max(beta.get(3).get(k+1) + branch1.get(k), beta.get(7).get(k+1) - branch1.get(k)));

            normalize(beta, k);

            calculateLLr(k);
        }
    }


    /**
     * Calculate LLR
     */
    private void calculateLLr(int k) {
        int expr0 = Math.max(alpha.get(0).get(k) - branch1.get(k) + beta.get(4).get(k+1),
                alpha.get(1).get(k) - branch1.get(k) + beta.get(0).get(k+1));

        int expr1 = Math.max(alpha.get(2).get(k) - branch2.get(k) + beta.get(1).get(k+1),
                alpha.get(3).get(k) - branch2.get(k) + beta.get(5).get(k+1));

        int expr2 = Math.max(alpha.get(4).get(k) - branch2.get(k) + beta.get(6).get(k+1),
                alpha.get(5).get(k) - branch2.get(k) + beta.get(2).get(k+1));

        int expr3 = Math.max(alpha.get(6).get(k) - branch1.get(k) + beta.get(3).get(k+1),
                alpha.get(7).get(k) - branch1.get(k) + beta.get(7).get(k+1));

        int expr4 = Math.max(alpha.get(0).get(k) + branch1.get(k) + beta.get(0).get(k+1),
                alpha.get(1).get(k) + branch1.get(k) + beta.get(4).get(k+1));

        int expr5 = Math.max(alpha.get(2).get(k) + branch2.get(k) + beta.get(5).get(k+1),
                alpha.get(3).get(k) + branch2.get(k) + beta.get(1).get(k+1));

        int expr6 = Math.max(alpha.get(4).get(k) + branch2.get(k) + beta.get(2).get(k+1),
                alpha.get(5).get(k) + branch2.get(k) + beta.get(6).get(k+1));

        int expr7 = Math.max(alpha.get(6).get(k) + branch1.get(k) + beta.get(8).get(k+1),
                alpha.get(7).get(k) + branch1.get(k) + beta.get(3).get(k+1));

        llr.add(Math.max(Math.max(expr0, expr1), Math.max(expr2, expr3)) -
                Math.max(Math.max(expr4, expr5), Math.max(expr6, expr7)));
    }

    /**
     * Calculate Extrinsic
     */
    private void calculateExtrinsic() {
        for (int i = 0; i < llr.size(); i++) {
            float expr = 0.75F * ((llr.get(i)) - sys.get(i));
            extrinsic.add(expr);
        }
    }

    public ArrayList<Integer> getLlr() {
        return llr;
    }

    public ArrayList<Float> getExtrinsic() {
        return extrinsic;
    }
}
