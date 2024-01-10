#pragma once

class Led {
public:
    static Led *getInstance();
    static Led* led_;
    void init();
    void toggle();
    void on();
    void off();

private:
    Led() {}
    ~Led() {}
    Led(const Led&) = delete; // Delete copy constructor
    Led& operator=(const Led&) = delete; // Delete assignment operator
};
