package com.poom.backend.api.dto.donation;

import com.poom.backend.util.ConvertUtil;
import lombok.*;
import org.web3j.poomcontract.PoomContract;

import java.math.BigInteger;
import java.time.LocalDateTime;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Getter
public class SmartContractDonationDto {
//    struct Donation { // 후원
//        string memberId;
//        uint256 donationId;
//        uint256 donationAmount; // 후원 금액
//        uint64 fundraiserId; // 모금 id
//        uint256 donationTime; // 모금 시간
//        uint8 isIssued; // nft 발급 여부
//    }

    public String memberId;
    Long donationId;
    Double donationAmount;
    Long fundraiserId;
    LocalDateTime donationTime;
    int isIssued; // nft 발급 여부

    // contract -> java
    public static SmartContractDonationDto fromDonationContract(PoomContract.Donation donation){

        return SmartContractDonationDto.builder()
                .memberId(donation.memberId)
                .donationAmount(ConvertUtil.weiToEther(donation.donationAmount))
                .fundraiserId(donation.fundraiserId.longValue())
                .donationTime(ConvertUtil.bigIntegerToDateTime(donation.donationTime))
                .isIssued(donation.isIssued.intValue())
                .build();
    }

    // java -> contract
    public static PoomContract.Donation toDonationContract(SmartContractDonationDto donationDto){
        return new PoomContract.Donation(
                donationDto.getMemberId(),
                BigInteger.valueOf(donationDto.getDonationId()),
                ConvertUtil.etherToWei(donationDto.getDonationAmount()),
                BigInteger.valueOf(donationDto.getFundraiserId()),
                ConvertUtil.dateTimeToBigInteger(donationDto.donationTime),
                BigInteger.valueOf(donationDto.getIsIssued())
        );
    }




}
