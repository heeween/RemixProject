// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ERC20.sol";

contract CrowdFund {
    event Launch(
        uint256 id,
        address creator,
        uint256 goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint256 id);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event UNPledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id);    
    event Refund(uint256 indexed id,address indexed caller,uint256 amount);
    struct Campaign {
        address creator;
        uint256 goal;
        uint256 pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }
    ERC20 public immutable token;
    uint256 public count;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public pledgeAmount;

    constructor(address _token) {
        token = ERC20(_token);
    }

    function launch(
        uint256 _goal,
        uint32 _startAt,
        uint32 _endAt
    ) external {
        require(_startAt > block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");
        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(
            _id > 0 &&
                _id <= count &&
                !campaign.claimed &&
                msg.sender == campaign.creator,
            "not campaign owner"
        );
        require(block.timestamp < campaign.startAt, "campaign started");
        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.startAt, "campaign not started");
        require(block.timestamp <= campaign.endAt, "campaign ended");
        campaign.pledged += _amount;
        pledgeAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.startAt, "campagin not started");
        require(block.timestamp <= campaign.endAt, "campagin ended");
        campaign.pledged -= _amount;
        pledgeAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
        emit UNPledge(_id, msg.sender, _amount);
    }

    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.endAt, "campaign not ended");
        require(campaign.pledged >= campaign.goal, "campaign failed");
        require(!campaign.claimed, "campaign claimed");
        campaign.pledged = 0;
        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);
        emit Claim(_id);
    }

    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "campaign not ended");
        require(campaign.pledged < campaign.goal, "campaign succeed");
        uint256 bal = pledgeAmount[_id][msg.sender];
        pledgeAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);
        emit Refund(_id,msg.sender,bal);
    }
}
