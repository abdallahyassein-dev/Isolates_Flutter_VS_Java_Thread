
public class Main {
    public static void main(String[] args) {
        DataProcessor processor = new DataProcessor();

        Thread thread1 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                processor.increment();
            }
        });

        Thread thread2 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                processor.increment();
            }
        });

        thread1.start();
        thread2.start();

        try {
            thread1.join();
            thread2.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("Counter: " + processor.getCounter());
    }
}
