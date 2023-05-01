// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 <0.9.0;

import "./Fundraiser.sol";

contract DonationProcess is FundraiserProcess {

    struct Donation { // 후원
        string memberId;
        uint256 donationId;
        uint256 donationAmount; // 후원 금액
        uint64 fundraiserId; // 모금 id
        string donationTime; // 모금 시간
        uint8 isIssued; // nft 발급 여부
    }


    uint64 private _donationId;

    // mapping(address => uint256) public balances;

    mapping(string => uint64[]) public memberDonationList; // memberid -> 후원id[]
    mapping(string => mapping(uint64=>uint64)) public memberToFundraiser; // memberid => fundraiserid -> 후원 id
    // mapping(uint64 => uint256) public myFundraiserCount; // shelterId => my fundraiserCount
    mapping(uint64=>Donation) public donations; //  후원 id -> 후원 내역
    mapping(uint64 => mapping(uint64=>Donation)) public fundraiserDonationList; // 모금 id -> 후원자들
    mapping(uint64 => uint256) public donationsCount; // 모금 id -> 후원자 수

    /*
     후원자 가져오려면
     멤버별 따로 빼기

    내 후원

    모금별 후원

    후원할 때 내가 했는지 안했는지 확인해야 한다 => memberid로

    모금 안에 후원 정보 저장
        - 후원자들 저장
        - 후원자 -> 후원 id
        - ㅁㅂ1ㅈㅈㅂ1ㅈ

    */


    // 후원자 목록
    function _getDonationList(uint64 _fundraiserId) internal view returns (Donation[] memory) {
        uint256 donationLength = donationsCount[_fundraiserId];
        Donation[] memory donationList = new Donation[](donationLength);

        for (uint64 i = 0; i < donationLength; i++) {
            donationList[i] = fundraiserDonationList[_fundraiserId][i];
        }

        return donationList;
    }


    // 내 후원 목록 가져오기
    function _getMyDonationList(string memory _memberId, uint64 page, uint64 size) internal view returns(Donation[] memory){

        uint256 myDonationCount = memberDonationList[_memberId].length;

        uint64 startIdx = page * size;
        uint64 endIdx = startIdx + size;
        uint256 length = endIdx > myDonationCount ? myDonationCount : endIdx;

        Donation[] memory myDonaionList = new Donation[](myDonationCount);

        for(uint64 i = startIdx; i < length; i++){
            myDonaionList[i-startIdx] = donations[memberDonationList[_memberId][i]];
        }
        return myDonaionList;

    }

    // nft isIssued -> 모금이 종료되면 1로 모두 변경
    function _setNftFundraiserEnded(uint64 _fundraiserId) internal {
        require(_getFundraiserDetail(_fundraiserId).isEnded==true, "Fundraiser is not ended.");

        uint256 donationLength = donationsCount[_fundraiserId];
        for (uint64 i = 0; i < donationLength; i++) {
            fundraiserDonationList[_fundraiserId][i].isIssued = 1;
        }
    }

    // donation 한개 가져오기
    function _getDonation(uint64 _id) internal view returns (Donation memory){
        return donations[_id];
    }


    ////////////////////////송금 구현해야함//////////////////////////////////////////

    // 후원
    function _donate(uint64 _fundraiserId, string memory _memberId, string memory _donationTime) public payable{
        require(msg.value >0, "Value must be more then 0");
        require(msg.value <= fundraisers[_fundraiserId].targetAmount-fundraisers[_fundraiserId].currentAmount, "Value must be little then target amount");
        require(fundraisers[_fundraiserId].isEnded = false,"Fundraiser is ended");

        if(donations[memberToFundraiser[_memberId][_fundraiserId]].donationAmount==0){
            Donation memory donation = Donation(
                {memberId:_memberId,
                donationId:_donationId++,
                fundraiserId:_fundraiserId,
                donationAmount:0,
                donationTime:"",
                isIssued: 0});
            donations[memberToFundraiser[_memberId][_fundraiserId]] = donation;

            memberDonationList[_memberId].push(_donationId);
            donations[_donationId] = donation;
            fundraiserDonationList[_fundraiserId][_donationId] = donation;
            donationsCount[_fundraiserId]+=1;
        }

        // balances[msg.sender]-=msg.value;
        // msg.sender.balances

        donations[memberToFundraiser[_memberId][_fundraiserId]].donationTime = _donationTime;
        donations[memberToFundraiser[_memberId][_fundraiserId]].donationAmount+=msg.value;
        fundraisers[_fundraiserId].currentAmount +=msg.value;

        // 목표 금액을 넘겼으면 끝내기
        if(fundraisers[_fundraiserId].currentAmount== fundraisers[_fundraiserId].targetAmount){
            _endFundraiser(_fundraiserId);
        }

    }

    function _transferToShelter(uint64 _fundraiserId) internal{
        Fundraiser memory fundraiser = _getFundraiserDetail(_fundraiserId);
        uint256 totalAmount = fundraiser.currentAmount;
        require(fundraiser.isEnded==true, "Fundraiser is not ended");
        require(totalAmount > 0, "No pending payments to withdraw");

    }
    //////////////////////////////////////////////////////////////////


}