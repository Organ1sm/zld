default: test

build:
    zig build

test: build 
    @echo -e "\e[32mPassed all tests\e[0m"
    @echo "Testing $@"
    @./tests/hello.sh
    @echo -e "\e[32mOK\e[0m"

clean: 
    rm -rf out/
