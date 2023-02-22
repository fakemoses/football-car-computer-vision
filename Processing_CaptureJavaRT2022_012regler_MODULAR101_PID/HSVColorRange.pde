// https://www.baeldung.com/java-enum-values

public enum HsvColorRange {
    RED1(new int[][]{{0, 50, 50} , {10, 255, 255} }),
    RED2(new int[][]{{170, 50, 50} , {180, 255, 255} }),
    YELLOW(new int[][]{{25, 50, 70} , {35, 255, 255} }),
    GREEN(new int[][]{{89, 255, 255} , {36, 50, 70} }),
    BLUE(new int[][]{{90, 50, 70} , {128, 255, 255} });
    
    private final int[][] range;
    
    private static final HashMap<String, HsvColorRange> map = new HashMap<>();
    
    static {
        for (HsvColorRange range : HsvColorRange.values()) {
            map.put(range.name(), range);
        }
    }
    
    HsvColorRange(int[][] range) {
        this.range = range;
    }
    
    public int[][] getRange() {
        return range;
    }
    
    public static HsvColorRange fromString(String name) {
        return map.get(name);
    }
}
