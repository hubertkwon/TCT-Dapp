

App = {
  web3Provider: null,
  contracts: {},
	  init: function() {
      $.ajaxSetup({async: false});
   return App.initWeb3();
  },

  initWeb3: function() {
	 if (typeof web3 !== 'undefined'){ //메타마스크 있는지 없는지 확인
     App.web3Provider = web3.currentProvider;
     web3 = new Web3(web3.currentProvider);
   }else {
      App.web3Provider = new web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
   }

   return App.initContract();
  },

  initContract: function() {
		$.getJSON('TCTDapp.json', function(data){
      App.contracts.TCTDapp = TruffleContract(data);//컨트랙 인스턴스화
      App.contracts.TCTDapp.setProvider(App.web3Provider);
      
    });

    $.getJSON('FlexibleToken.json', function(data){
      App.contracts.FlexibleToken = TruffleContract(data);//컨트랙 인스턴스화
      App.contracts.FlexibleToken.setProvider(App.web3Provider);
      
    });


    web3.eth.getAccounts(function(error, accounts){
      if(error) {
        console.log(error);
      }
      
      var account = accounts[0];



      if(account === null || account === undefined/*회원등록해주세요 조건추가*/) //오른쪽맨위 주소 뜨게하는것
      {
        document.getElementById("contractAddress").innerHTML="메타마스크에 로그인해주세요";
        document.getElementById("isRegist").innerHTML = "안녕하세요";
        $("#isLogined").attr("href", "index.html");
      }
      else{
        
        document.getElementById("contractAddress").innerHTML = account;
       
      }

      web3.eth.getBalance(account, function (error, result) { //이더개수 가져오는것 오른쪽 맨위
        if (!error) {
          
            var Ether_value = web3.fromWei(result,'ether');
        } else {
            console.error(error);
        }
        document.getElementById("Ether_value").innerHTML = Ether_value;
    });


    App.contracts.FlexibleToken.deployed().then(function(instance){  // 토큰개수 가져오는 것 오른쪽 맨위
      
      var token_value = instance.balanceOf(account);

      token_value.then(function(result) { 
        document.getElementById("token_value").innerHTML = result;//will log results.
     });
      
    });

    App.contracts.TCTDapp.deployed().then(function(instance){  //사람인지 아닌지 확인하기
      var is_person = instance.isPerson(account)
      is_person.then(function(result){
        console.log(result);
        if(result === true)
        {
          document.getElementById("isRegist").innerHTML = "안녕하세요";
          $("#isLogined").attr("href", "index.html");
          
        }
        else
        {
          document.getElementById("isRegist").innerHTML = "회원등록";
          $("#isLogined").attr("href", "#");
        }
        //console.log(result);
      })
    
    });

    });
  },

  callEther: function() {	


  web3.eth.getAccounts(function(error, accounts){
    if(error) {
      console.log(error);
    }
    
    var account = accounts[0];
    var Ether_value = web3.fromWei(eth.getBalance(account), "ether")
    document.getElementById("Ether_value").innerHTML = Ether_value;
  
  });
},

  setPerson: function() {	


    var Name = $('#Name').val();
   

  web3.eth.getAccounts(function(error, accounts){
    if(error) {
      console.log(error);
    }
    
    var account = accounts[0];
   

  App.contracts.TCTDapp.deployed().then(function(instance){
    return instance.setPerson(Name, {from: account});
  }).then(function() {
    $('#Name').val('');
  
  });
    console.log(account);
  });
},


  
  setCar: function() {	
    var car_registed_string = $('#car_registed_string').val();
    var model = $('#model').val();

  web3.eth.getAccounts(function(error, accounts){
    if(error) {
      console.log(error);
    }
    
    var account = accounts[0];
   

  App.contracts.TCTDapp.deployed().then(function(instance){
    return instance.setCar(car_registed_string, model, {from: account});
  }).then(function() {
    $('#car_registed_string').val('');
    $('#model').val('');
    //return App.callCar();
    
  })
    console.log(account);
  });
},

setRepairInfo: function() {	
  
  var materialContactFormName = $('#materialContactFormName').val();
  

  
  var repair_Check = document.getElementById('form_check_input').value;
  var repair_Check_Value;
  if(repair_Check === 'Repair_Ok')
  {
    repair_Check_Value = document.getElementById('ok').value;
  }
  else if(repair_Check === 'Repair_No')
  {
    repair_Check_Value = document.getElementById('no').value;
  }
  else if(repair_Check === 'Repair_Ongoing')
  {
    repair_Check_Value = document.getElementById('ongoing').value;
  }
  
  var repair_Check_Values = true;
  // var checkedValue = $('.form-check-label:checked').val();


web3.eth.getAccounts(function(error, accounts){
  if(error) {
    console.log(error);
  }
  
  var account = accounts[0];
 

App.contracts.TCTDapp.deployed().then(function(instance){
  return instance.setCar(materialContactFormName, repair_Check_Value, repair_Check_Values, {from: account});
}).then(function() {
  //return App.callCar();
  
})
console.log(materialContactFormName);
console.log(repair_Check_Value);
console.log(repair_Check_Values);
 
});
},




  callCar: function() {
    web3.eth.getAccounts(function(error, accounts){
      if(error) {
        console.log(error);
      }
  
      var account = accounts[0];

      App.contracts.TCTDapp.deployed().then(function(instance){
        return instance.getMyCarList();
      }).then(function(cars){
        for(i = 0; i<cars.length; i++){
          document.write(cars[i]);
          document.write("\n");
        }
        console.log(cars);
        console.log("load complete");
      });
});
  },

  withdrawCall: function() {
    var withdraw_Address = $('#withdraw_Address').val();
    var withdraw_value = $('#withdraw_value').val();

    web3.eth.getAccounts(function(error, accounts){
      if(error) {
        console.log(error);
      }
  
      var account = accounts[0];

      App.contracts.FlexibleToken.deployed().then(function(instance){
         return instance.transfer(withdraw_Address,withdraw_value,{from: account});
      }).then(function(){
         $('#withdraw_Address').val('');
         $('#withdraw_value').val('');
      });
});
  },


  ownerChange: function() {	
    var toAddress = $('#toAddress').val();
    var carNum_o = $('#carNum_o').val();

  web3.eth.getAccounts(function(error, accounts){
    if(error) {
      console.log(error);
    }
    
    var account = accounts[0];
   

  App.contracts.TCTDapp.deployed().then(function(instance){
    return instance.ownerChange(account,toAddress, carNum_o);
  }).then(function() {
    $('#toAddress').val('');
    $('#carNum_o').val('');    
  })
    console.log(account);
  });
},
  

  loadAccount: function() {
    web3.eth.getAccounts(function(error, accounts){
      if(error) {
        console.log(error);
      }
  
      var account = accounts[0];

      App.contracts.TCTDapp.deployed().then(function(instance){
        return document.write(account);
      });
      
   

});
  },

	
  listenToEvents: function() {
	
  }
};

$(function() {
  $(window).load(function() {
    App.init();
    
  });
});
