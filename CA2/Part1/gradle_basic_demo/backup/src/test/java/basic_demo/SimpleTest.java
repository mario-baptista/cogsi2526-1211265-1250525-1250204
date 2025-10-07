package basic_demo;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class SimpleTest {
    @Test
    void simpleTest() {
        // trivial test that doesn't rely on your application code
        assertEquals(2, 1 + 1);
    }
}