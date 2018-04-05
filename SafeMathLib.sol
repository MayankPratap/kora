pragma solidity 0.4.21;
pragma experimental ABIEncoderV2; 


library SafeMathLib{

    function times(uint64 a, uint64 b) public pure returns (uint64){

        uint64 c = a*b; 

        assert (a==0 || c/a == b);

        return c; 

    }

    function minus(uint64 a, uint64 b ) public pure returns (uint64) {


        assert(b<=a);

        return a-b;

    }

    function plus(uint64 a, uint64 b) public pure returns (uint64){

        uint64 c= a+b; 
        assert(c>=a && c>=b) ;
        return c;

    }

    function divided(uint64 a, uint64 b) public pure returns (uint64) {
        require(b > 0);
        uint64 c = a / b;
        return c;
    }

    function assert(bool assertion) private{

        if(!assertion) throw;

    }
}

