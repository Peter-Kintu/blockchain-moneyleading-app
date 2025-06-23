// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract is a simplified example.
// For a production system, you would use proper ERC-20 interfaces (IERC20)
// and standard patterns like 'approve' and 'transferFrom' for token handling.
// You would also implement robust oracle integration for collateral value checks.

contract P2PLoan {
    // --- Loan Parameters ---
    uint256 public loanAmount;          // Amount of loan asset (e.g., DAI)
    uint256 public collateralAmount;    // Amount of collateral asset (e.g., WETH)
    uint256 public interestRate;        // Annual interest rate (e.g., 500 = 5%)
    uint256 public loanDuration;        // Duration in seconds (e.g., 30 days)

    // --- Participants ---
    address payable public lender;      // Address of the lender
    address payable public borrower;    // Address of the borrower

    // --- State Variables ---
    uint256 public loanStartTime;       // Timestamp when loan was disbursed
    uint256 public loanEndTime;         // Timestamp when loan is due
    bool public isDisbursed;            // True if loan has been disbursed
    bool public isRepaid;               // True if loan has been fully repaid
    bool public isLiquidated;           // True if collateral has been claimed
    bool public collateralProvided;     // <--- ADD THIS NEW STATE VARIABLE

    // Assume fixed token addresses for simplicity in this example
    // In a real app, these would be set during deployment or as parameters
    address payable public loanAssetAddress;     // Address of the ERC-20 token for the loan (e.g., DAI)
    address payable public collateralAssetAddress; // Address of the ERC-20 token for the collateral (e.g., WETH)

    // --- Events ---
    event LoanRequested(address indexed _borrower, uint256 _loanAmount, uint256 _collateralAmount, uint256 _duration, uint256 _interestRate);
    event LoanDisbursed(address indexed _borrower, address indexed _lender, uint256 _amount, uint256 _disbursementTime, uint256 _endTime);
    event RepaymentMade(address indexed _borrower, uint256 _amountPaid, uint256 _remainingDue);
    event CollateralReleased(address indexed _borrower, uint256 _collateralAmount);
    event CollateralLiquidated(address indexed _lender, uint256 _collateralAmount);

    // --- Constructor ---
    constructor(
        address payable _lender,
        address payable _borrower,
        uint256 _loanAmount,
        uint256 _collateralAmount,
        uint256 _interestRate, // Annual rate, multiplied by 10000 to represent 1% (e.g., 500 for 5%)
        uint256 _loanDuration, // In seconds
        address payable _loanAssetAddress,
        address payable _collateralAssetAddress
    ) {
        require(_lender != address(0), "Lender cannot be zero address");
        require(_borrower != address(0), "Borrower cannot be zero address");
        require(_loanAmount > 0, "Loan amount must be greater than zero");
        require(_collateralAmount > 0, "Collateral amount must be greater than zero");
        require(_interestRate <= 10000, "Interest rate cannot exceed 100%"); // Max 100% per year
        require(_loanDuration > 0, "Loan duration must be greater than zero");

        lender = _lender;
        borrower = _borrower;
        loanAmount = _loanAmount;
        collateralAmount = _collateralAmount;
        interestRate = _interestRate;
        loanDuration = _loanDuration;
        loanAssetAddress = _loanAssetAddress;
        collateralAssetAddress = _collateralAssetAddress;
        collateralProvided = false; // <--- INITIALIZE NEW STATE VARIABLE

        emit LoanRequested(borrower, loanAmount, collateralAmount, loanDuration, interestRate);
    }

    // --- Modifiers ---
    modifier onlyLender() {
        require(msg.sender == lender, "Only lender can call this function");
        _;
    }

    modifier onlyBorrower() {
        require(msg.sender == borrower, "Only borrower can call this function");
        _;
    }

    // --- Core Functions ---

    function fundLoan() external payable onlyLender {
        require(!isDisbursed, "Loan already disbursed");
        require(msg.value >= loanAmount, "Lender must send exact loan amount (for ETH/DAI example)");
        require(collateralProvided, "Collateral must be provided before loan disbursement"); // <--- ADD THIS REQUIREMENT

        isDisbursed = true;
        loanStartTime = block.timestamp;
        loanEndTime = block.timestamp + loanDuration;

        borrower.transfer(loanAmount);

        emit LoanDisbursed(borrower, lender, loanAmount, loanStartTime, loanEndTime);
    }

    function provideCollateral() external payable onlyBorrower {
        require(!isDisbursed, "Cannot provide collateral after loan disbursement");
        require(!collateralProvided, "Collateral already provided"); // <--- ADD THIS REQUIREMENT
        require(msg.value >= collateralAmount, "Borrower must send exact collateral amount (for ETH/WETH example)");
        
        // At this point, `msg.value` has been sent to the contract's address
        // You would typically use IERC20.transferFrom here for actual tokens.

        collateralProvided = true; // <--- SET THE NEW STATE VARIABLE TO TRUE
    }

    function calculateAmountDue() public view returns (uint256) {
        if (!isDisbursed || isRepaid) {
            return loanAmount;
        }

        uint256 timeElapsed = block.timestamp - loanStartTime;
        if (timeElapsed > loanDuration) {
            timeElapsed = loanDuration;
        }

        uint256 interest = (loanAmount * interestRate * timeElapsed) / (10000 * loanDuration);
        return loanAmount + interest;
    }

    function repayLoan() external payable onlyBorrower {
        require(isDisbursed, "Loan not disbursed yet");
        require(!isRepaid, "Loan already repaid");
        require(msg.value >= calculateAmountDue(), "Not enough sent to repay loan (for ETH/DAI example)");
        
        isRepaid = true;

        lender.transfer(calculateAmountDue());
        
        // This is where you'd typically release collateral using IERC20.transfer
        borrower.transfer(collateralAmount); // Simulates token transfer of collateral
        collateralProvided = false; // <--- RESET COLLATERAL STATUS UPON REPAYMENT
        emit RepaymentMade(borrower, calculateAmountDue(), 0);
        emit CollateralReleased(borrower, collateralAmount);
    }

    function liquidateCollateral() external onlyLender {
        require(isDisbursed, "Loan not disbursed");
        require(!isRepaid, "Loan already repaid");
        require(block.timestamp > loanEndTime, "Loan is not yet overdue");
        require(!isLiquidated, "Collateral already liquidated");
        require(collateralProvided, "No collateral to liquidate"); // <--- ADD THIS REQUIREMENT

        isLiquidated = true;
        
        // This is where you'd typically claim collateral using IERC20.transfer
        lender.transfer(collateralAmount); // Simulates token transfer of collateral
        collateralProvided = false; // <--- RESET COLLATERAL STATUS UPON LIQUIDATION
        emit CollateralLiquidated(lender, collateralAmount);
    }

    function withdrawAccidentalEth() external payable {
        // Only contract owner can withdraw this (implement owner check later)
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable { }
}