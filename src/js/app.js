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
		  document.getElementById("token_value1").innerHTML = result;
	   });
		
	  });
  
	  App.contracts.TCTDapp.deployed().then(function(instance){  //사람인지 아닌지 확인하기
		var is_person = instance.isPerson(account);
		is_person.then(function(result){
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
  
	  App.contracts.TCTDapp.deployed().then(function(instance){
  
		var info_escrows = instance.escrows.call(3);
  
		info_escrows.then(function(result){
		  console.log(result[3]);
		  console.log(result);
		  
		});
	  });
  
	  App.contracts.TCTDapp.deployed().then(function(instance){  //판매자 주소
  
		var info_escrows = instance.escrows.call(1); // 거래번호로 바꿔줘야함
  
  
		info_escrows.then(function(result){
		  var seller_CarName = result[1];
		  if(seller_CarName ==="")
		  {
			document.getElementById("seller_CarName").innerHTML = "";
		  }
		  else{
			document.getElementById("seller_CarName").innerHTML = seller_CarName;
		  }
		  
  
  
		  var seller_address = result[3]; //DB에서 가져올 정보
		  if(seller_address ==="0x0000000000000000000000000000000000000000")
		  {
			document.getElementById("seller_address").innerHTML ="";
		  }
		  else{
			document.getElementById("seller_address").innerHTML = seller_address;
		  }
		  
		  
  
		  var buyer_address = result[4];
		 
			document.getElementById("buyer_address").innerHTML = account;
		  
		  
  
  
		  var deposite_is = result[5];
		  if(deposite_is === true)
		  {
			document.getElementById("deposite_is").innerHTML = "입금완료"
		  }
		  else{
			document.getElementById("deposite_is").innerHTML = "입금대기"
		  }
  
  
		  var buyer_approve = result[6];
		  if(buyer_approve === true)
		  {
			document.getElementById("buyer_approve").innerHTML = "구매자 승인완료"
		  }
		  else{
			document.getElementById("buyer_approve").innerHTML = "구매자 승인대기"
		  }
  
		  var seller_approve = result[7];
		  if(seller_approve === true)
		  {
			document.getElementById("seller_approve").innerHTML = "구매자 승인완료"
		  }
		  else{
			document.getElementById("seller_approve").innerHTML = "구매자 승인대기"
		  }
  
  
		  var lived = result[8];
		  if(lived === true)
		  {
			document.getElementById("lived").innerHTML = "거래 진행중"
		  }
		  else{
			document.getElementById("lived").innerHTML = "거래 대기중"
		  }
		});
  
		
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
  
  
	var repair_Check = $('input[name="inlineMaterialRadiosExample"]:checked').val();
	var repair_Check_Value;
	if(repair_Check === 'Repair_Ok')
	{
	  repair_Check_Value = true;
	}
	else if(repair_Check === 'Repair_No')
	{
	  repair_Check_Value = false;
	}
	
  
  
	var form_check_input1 = $('input[name="RpInfo"]:checked').val();
  
  
  
  
  web3.eth.getAccounts(function(error, accounts){
	if(error) {
	  console.log(error);
	}
	
	var account = accounts[0];
   
  
  App.contracts.TCTDapp.deployed().then(function(instance){
	return instance.setRepairInfo(materialContactFormName,  form_check_input1, repair_Check_Value, {from: account});
  }).then(function() {
	//return App.callCar();
	
  })
  console.log(materialContactFormName);
  console.log(form_check_input1);
  console.log(repair_Check_Value);
  
   
  });
  },
  
  
  
  
	callCar: function() {
	  var materialContactFormName = $('#materialContactFormName').val();
  
	  web3.eth.getAccounts(function(error, accounts){
		if(error) {
		  console.log(error);
		}
	
		var account = accounts[0];
	  
		App.contracts.TCTDapp.deployed().then(function(instance){
		  
		  var count = instance.getRepairCount(materialContactFormName);
  
		  count.then(function(result){
			
			var count = result.toNumber();
			
			
			  
			return instance.getRepairInfo(materialContactFormName, 0,{from: account});
			  
			
		  }).then(function(repair_result){
			  console.log(repair_result);
  
		  })
		  
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
  
	CoinApprove: function() {	
	  var Coin_Approve = $('#Coin_Approve').val();
	web3.eth.getAccounts(function(error, accounts){
	  if(error) {
		console.log(error);
	  }
	  
	  var account = accounts[0];
	 
  
	App.contracts.FlexibleToken.deployed().then(function(instance){
	  return instance.approve("0xb9779547EdcCAbC4a9Bc10c2444DBe02A56dEc20", Coin_Approve, {from: account});   //코인컨트랙 바뀌면 반드시 바꿔야함
	}).then(function() {
	  $('#Coin_Approve').val('');
	  //return App.callCar();
	  
	})
	  console.log(account);
	});
  },
  
  deposit: function() {	
  
	//var Trade_Num = $('#Trade_Num').val();
  web3.eth.getAccounts(function(error, accounts){
	if(error) {
	  console.log(error);
	}
	
	var account = accounts[0];
   
  
  App.contracts.TCTDapp.deployed().then(function(instance){
	 instance.deposit(2);   //거래번호 자동으로 등록되도록 '1'을 바꿔야함
  }).then(function() {
	//return App.callCar();
	
  });
	console.log(account);
  });
  },
  
  
  Create: function() {	
  
	//var Trade_Num = $('#Trade_Num').val();
  web3.eth.getAccounts(function(error, accounts){
	if(error) {
	  console.log(error);
	}
	
	var account = accounts[0];
   
  
  App.contracts.TCTDapp.deployed().then(function(instance){
	return instance.escrowCreate("BBB",1000,"0x11209149dbded216f234fc517e93eaad83e969d8", {from: account});   //차대번호 , 가격, 구매자주소순서로 변수로 바꿔주기
  }).then(function() {
	//$('#Trade_Num').val('');
	//return App.callCar();
	
  })
	console.log(account);
  });
  },
	
  
  buyerApprove: function() {	
  
	//var Trade_Num = $('#Trade_Num').val();
  web3.eth.getAccounts(function(error, accounts){
	if(error) {
	  console.log(error);
	}
	
	var account = accounts[0];
   
  
  App.contracts.TCTDapp.deployed().then(function(instance){
	return instance.Approve(2, {from: account});   //거래번호
  }).then(function() {
	//$('#Trade_Num').val('');
	//return App.callCar();
	
  })
	console.log(account);
  });
  },
  
  sellerApprove: function() {	
  
	//var Trade_Num = $('#Trade_Num').val();
  web3.eth.getAccounts(function(error, accounts){
	if(error) {
	  console.log(error);
	}
	
	var account = accounts[0];
   
  
  App.contracts.TCTDapp.deployed().then(function(instance){
	return instance.Approve(2, {from: account}); 
  }).then(function() {
	//$('#Trade_Num').val('');
	//return App.callCar();
	
  })
	console.log(account);
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
        document.getElementById("token_value1").innerHTML = result;
     });
      
    });

    App.contracts.TCTDapp.deployed().then(function(instance){  //사람인지 아닌지 확인하기
      var is_person = instance.isPerson(account);
      is_person.then(function(result){
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

    App.contracts.TCTDapp.deployed().then(function(instance){

      var info_escrows = instance.escrows.call(3);

      info_escrows.then(function(result){
        console.log(result[3]);
        console.log(result);
        
      });
    });

    App.contracts.TCTDapp.deployed().then(function(instance){  //판매자 주소

      var info_escrows = instance.escrows.call(3); // 거래번호로 바꿔줘야함


      info_escrows.then(function(result){
        var seller_CarName = result[1];
        if(seller_CarName ==="")
        {
          document.getElementById("seller_CarName").innerHTML = "";
        }
        else{
          document.getElementById("seller_CarName").innerHTML = seller_CarName;
        }
        


        var seller_address = result[3]; //DB에서 가져올 정보
        if(seller_address ==="0x0000000000000000000000000000000000000000")
        {
          document.getElementById("seller_address").innerHTML ="";
        }
        else{
          document.getElementById("seller_address").innerHTML = seller_address;
        }
        
        

        var buyer_address = result[4];
       
          document.getElementById("buyer_address").innerHTML = account;
        
        


        var deposite_is = result[5];
        if(deposite_is === true)
        {
          document.getElementById("deposite_is").innerHTML = "입금완료"
        }
        else{
          document.getElementById("deposite_is").innerHTML = "입금대기"
        }


        var buyer_approve = result[6];
        if(buyer_approve === true)
        {
          document.getElementById("buyer_approve").innerHTML = "구매자 승인완료"
        }
        else{
          document.getElementById("buyer_approve").innerHTML = "구매자 승인대기"
        }

        var seller_approve = result[7];
        if(seller_approve === true)
        {
          document.getElementById("seller_approve").innerHTML = "구매자 승인완료"
        }
        else{
          document.getElementById("seller_approve").innerHTML = "구매자 승인대기"
        }


        var lived = result[8];
        if(lived === true)
        {
          document.getElementById("lived").innerHTML = "거래 진행중"
        }
        else{
          document.getElementById("lived").innerHTML = "거래 대기중"
        }
      });

      
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


  var repair_Check = $('input[name="inlineMaterialRadiosExample"]:checked').val();
  var repair_Check_Value;
  if(repair_Check === 'Repair_Ok')
  {
    repair_Check_Value = true;
  }
  else if(repair_Check === 'Repair_No')
  {
    repair_Check_Value = false;
  }
  


  var form_check_input1 = $('input[name="RpInfo"]:checked').val();




web3.eth.getAccounts(function(error, accounts){
  if(error) {
    console.log(error);
  }
  
  var account = accounts[0];
 

App.contracts.TCTDapp.deployed().then(function(instance){
  return instance.setRepairInfo(materialContactFormName,  form_check_input1, repair_Check_Value, {from: account});
}).then(function() {
  //return App.callCar();
  
})
console.log(materialContactFormName);
console.log(form_check_input1);
console.log(repair_Check_Value);

 
});
},




  callCar: function() {
    var materialContactFormName = $('#materialContactFormName').val();

    web3.eth.getAccounts(function(error, accounts){
      if(error) {
        console.log(error);
      }
  
      var account = accounts[0];
    
      App.contracts.TCTDapp.deployed().then(function(instance){
        
        var count = instance.getRepairCount(materialContactFormName);

        count.then(function(result){
          
          var count = result.toNumber();
          
          
            
          return instance.getRepairInfo(materialContactFormName, 0,{from: account});
            
          
        }).then(function(repair_result){
            console.log(repair_result);

        })
        
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

  CoinApprove: function() {	
    var Coin_Approve = $('#Coin_Approve').val();
  web3.eth.getAccounts(function(error, accounts){
    if(error) {
      console.log(error);
    }
    
    var account = accounts[0];
   

  App.contracts.FlexibleToken.deployed().then(function(instance){
    return instance.approve("0xb9779547EdcCAbC4a9Bc10c2444DBe02A56dEc20", Coin_Approve, {from: account});   //코인컨트랙 바뀌면 반드시 바꿔야함
  }).then(function() {
    $('#Coin_Approve').val('');
    //return App.callCar();
    
  })
    console.log(account);
  });
},

deposit: function() {	

  //var Trade_Num = $('#Trade_Num').val();
web3.eth.getAccounts(function(error, accounts){
  if(error) {
    console.log(error);
  }
  
  var account = accounts[0];
 

App.contracts.TCTDapp.deployed().then(function(instance){
   instance.deposit(2);   //거래번호 자동으로 등록되도록 '1'을 바꿔야함
}).then(function() {
  //return App.callCar();
  
});
  console.log(account);
});
},


Create: function() {	

  //var Trade_Num = $('#Trade_Num').val();
web3.eth.getAccounts(function(error, accounts){
  if(error) {
    console.log(error);
  }
  
  var account = accounts[0];
 

App.contracts.TCTDapp.deployed().then(function(instance){
  return instance.escrowCreate("BBB",1000,"0x11209149dbded216f234fc517e93eaad83e969d8", {from: account});   //차대번호 , 가격, 구매자주소순서로 변수로 바꿔주기
}).then(function() {
  //$('#Trade_Num').val('');
  //return App.callCar();
  
})
  console.log(account);
});
},
  

buyerApprove: function() {	

  //var Trade_Num = $('#Trade_Num').val();
web3.eth.getAccounts(function(error, accounts){
  if(error) {
    console.log(error);
  }
  
  var account = accounts[0];
 

App.contracts.TCTDapp.deployed().then(function(instance){
  return instance.Approve(2, {from: account});   //거래번호
}).then(function() {
  //$('#Trade_Num').val('');
  //return App.callCar();
  
})
  console.log(account);
});
},

sellerApprove: function() {	

  //var Trade_Num = $('#Trade_Num').val();
web3.eth.getAccounts(function(error, accounts){
  if(error) {
    console.log(error);
  }
  
  var account = accounts[0];
 

App.contracts.TCTDapp.deployed().then(function(instance){
  return instance.Approve(2, {from: account}); 
}).then(function() {
  //$('#Trade_Num').val('');
  //return App.callCar();
  
})
  console.log(account);
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
