public class TypeCastingExample {
    public static void main(String[] args) {

        double d = 99.99;
        int i = (int)d;

        int num = 50;
        double value = (double)num;

        System.out.println("Double Value : " + d);
        System.out.println("After Casting to Int : " + i);

        System.out.println("Integer Value : " + num);
        System.out.println("After Casting to Double : " + value);
    }
}
