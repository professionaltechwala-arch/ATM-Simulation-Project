#!/bin/bash
echo "Content-type: text/html"
echo ""

if [ "$REQUEST_METHOD" = "POST" ]; then
	read -N "$CONTENT_LENGTH" QUERY_STRING
fi
[ -z "$QUERY_STRING" ] && QUERY_STRING=""

# This sends the CSS styling to the browser
cat <<EOF
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>

<style>
  body { 
    font-family: 'Arial', sans-serif;  
    color: #87CEEB;
    margin: 0;
    padding: 0;
    text-weight: bold;
    text-transform: uppercase; 
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8);
    background-image: url('atm_data/atmui.jpg');
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover; 
    background-attachment: fixed;   
 }

 h1 {  margin-bottom: 10px;}
 .top-section {
   padding: 20px; 
   display: flex;
   flex-direction:column;
   justify-content: center;
   align-items: center;
 }

 .style-txt {
   height: 90%; 
   color: pink; 
   display: flex;
   justify-content: center;
   align-items: center;   
   text-align: center; 
 }

 button { 
   width: 100%;
   padding: 20px; 
   background: rgba(255, 255, 255, 0.1);  
   border: 1px solid rgba(255, 255, 255, 0.1);
   border-radius: 25px;     
   color: #87CEEB;
   font-weight: bold;    
   font-size: 20px;
   text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
   backdrop-filter: blur(5px);
   -webkit-backdrop-filter: blur(5px);
   box-shadow: 0px 1px 40px rgba(255, 255, 255, 0.1);
   cursor: pointer;
   transition: transform 0.2s ease;
 }

 button:hover {
   background: rgba(255, 255, 255, 0.2);
   box-shadow: 0px 1px 40px rgba(255, 255, 255, 0.2);
   transform: translateY(-2px);
 }

 .back-btn{ 
   background: rgba(220, 20, 60, 0.4);
   backdrop-filter: blur(5px);
   -webkit-backdrop-filter: blur(5px);
   box-shadow: 0 8px 32px 0 rgba(220, 20, 60, 0.3);
 }

 .back-btn:hover {
   background: rgba(200, 20, 60, 0.5);
   box-shadow: 0 8px 32px 0 rgba(220, 20, 60, 0.4);
 }

 .float-right{ 
    position: fixed; 
    bottom: 20px;
    right: 20px;
    width: 40%;
    max-width:250px;
    gap: 40px;
    display: flex;
    flex-direction: column; 
 }

 .float-left{  
   width: 40%;
   max-width:250px;
   position: fixed; 
   bottom: 20px;
   gap: 40px;
   left: 20px;
   display: flex;
   flex-direction: column;
 }

 input { 
   width: 40%; 
   padding: 10px; 
   margin: 10px 0; 
   color: #87CEEB;
   padding: 12px 15px;
   background: rgba(255, 255, 255, 0.1);
   box-sizing: border-box; 
   border: 1px solid rgba(255, 255, 255, 0.2);
   backdrop-filter: blur(10px);
   -webkit-backdrop-filter:blur (10px);
   border-radius: 8px;
   outline: none;
   box-sizing: border-box;
 }

 .input-container{
   display: flex;
   flex-direction:column;
   justify-content: center;
   align-items: center;
   text-align: center;
   height: 90%;
 }
   
 input:hover {
   border-color: #87CEEB;
   background: rgba(255, 255, 255, 0.2);
 }

 input:focus {
   background: rgba(255, 255, 255, 0.2);
   border: 1px solid #87CEEB;
   box-shadow: 0 0 15px rgba(135, 206, 235, 0.2);
 }

 input::-ms-reveal,input::-webkit-reveal{
   display: none;
 }

 .error{
   color: #FF5252;
   margin: 10px;
   font-weight: bold;       
 }

 .sucess{
   color: #2ECC71;
   font-size: 20px;
   font-weight: bold;
   margin: 0;
 }
</style>
<body class="atm-card">
EOF

# Use a directory we KNOW Apache can access
data_dir="./atm_data"
pin_file="$data_dir/atm_pin.txt"
bal_file="$data_dir/atm_bal.txt"

#If the directory doesn't exist, try to create it
[ ! -d "$data_dir" ] && mkdir -p "$data_dir" 2>/dev/null

#If the files don't exist, create them with initial values
if [ ! -f "$pin_file" ]; then
    printf "1234" > "$pin_file"
    printf "1000" > "$bal_file"
    chmod 666 "$pin_file" "$bal_file" 2>/dev/null
fi

#Read the values
pin=$(cat "$pin_file" 2>/dev/null | tr -dc '0-9')
balance=$(cat "$bal_file" 2>/dev/null | tr -dc '0-9')

choice=$(echo "$QUERY_STRING" | sed -n 's/^.*choice=\([^&]*\).*$/\1/p')
amt=$(echo "$QUERY_STRING" | sed -n 's/^.*amt=\([^&]*\).*$/\1/p')
rpin=$(echo "$QUERY_STRING" | sed -n 's/^.*rpin=\([^&]*\).*$/\1/p')
npin=$(echo "$QUERY_STRING" | sed -n 's/^.*npin=\([^&]*\).*$/\1/p')
cpin=$(echo "$QUERY_STRING" | sed -n 's/^.*cpin=\([^&]*\).*$/\1/p')


save_data(){

    printf "%s" "$pin" > "$pin_file"
    printf "%s" "$balance" > "$bal_file"

}

back_button(){

    echo "<a href='/ATM_Project/atm.sh?choice=login&rpin=$pin'>"
    echo " <div class='float-left'><button type='button' class='back-btn'>MENU</button></a>"
    echo "<a href='/ATM_Project/atm.sh'>"
    echo "<button type='button' class='back-btn'>CANCEL</button></div>"
    echo "</a>"

}

cencel_button(){

    echo "<a href='/ATM_Project/atm.sh'>"
    echo " <div class='float-left'><button type='button' class='back-btn'>CANCEL</button>"
    echo "</div></a>"

}

#Method for genereting pin
generate_pin(){

    #Generates a 4-digit OTP
    otp=$(shuf -i 1000-9999 -n 1)
      	
    input_otp=$(echo "$QUERY_STRING" | sed -n 's/^.*input_otp=\([^&]*\).*$/\1/p')
    hidden_otp=$(echo "$QUERY_STRING" | sed -n 's/^.*hidden_otp=\([^&]*\).*$/\1/p')

    echo "<form action='/ATM_Project/atm.sh' method='POST'>"
    echo "<div class='input-container'>"

    if [[ "$hidden_otp" == "$input_otp" && "$npin" == "$cpin" && ${#npin} -eq 4 ]]; then

        pin=$npin	
	echo "<p class='sucess'>Pin generated successfully.</p>"         
 	cencel_button      
	save_data
    else
	
	if [[ "$npin" != "$cpin" ]]; then
		
	    echo "<p class='error'>New Pin Mismatch!</p>"
	
        elif [[ -n "$input_otp" && "$hidden_otp" != "$input_otp" ]]; then
            
	    echo "<p class='error'>Invalid OTP!</p>"

        fi
               	
	echo "<h5>Your OTP is: $otp</h5>"                
	echo "<input type='hidden' name='choice' value='gen_pin'>"		
	echo "  <input type='hidden' name='hidden_otp' value='$otp'>"                 
	echo "<label for='input_otp'>Enter OTP:</label><input id='input_otp' type='password' name='input_otp' maxlength='4' inputmode='numeric' pattern='[0-9]*' required>"                
	echo "<label for='input_npin'>Enter New PIN:</label><input id='input_npin' type='password' name='npin' maxlength='4' inputmode='numeric' pattern='[0-9]*' required>"                
	echo "<label for='input_cpin'>Confirm PIN:</label><input id='input_cpin' type='password' name='cpin' maxlength='4' inputmode='numeric' pattern='[0-9]*' required></div>"                
	echo "<div class='float-right'><button type='submit' >GENERATE PIN</button></div>"   
	cencel_button                 
	echo "</form>"

    fi

}

#Method for change pin 
change_pin(){
        
    echo "<form action='/ATM_Project/atm.sh' method='POST'>"        
    echo "<div class='input-container'>"
        
    if [[ "$pin" == "$rpin" && "$npin" == "$cpin" && ${#npin} -eq 4 ]]; then

	pin=$npin
               	
	echo "<p class='sucess'>Pin changed successfully.</p>"
       	cencel_button
        save_data

    else
	
	if [[ -n "$rpin" && "$pin" != "$rpin" ]]; then

            echo "<p class='error'>Current Pin is Incorrect!</p>"

	elif [[ "$npin" != "$cpin" ]]; then

            echo "<p class='error'>New Pin Mismatch!</p>"

	fi
        echo "<input type='hidden' name='choice' value='chan_pin'>"
	echo "<label for='input_pin'>Enter Current PIN:</label>"
	echo "<input id='input_pin' type='password' name='rpin' maxlength='4' inputmode='numeric' pattern='[0-9]*' required>"
        echo "<label for='input_npin'>Enter New PIN:</label><input id='input_npin' type='password' name='npin' maxlength='4' inputmode='numeric' pattern='[0-9]*' required>"
        echo "<label for='input_cpin'>Confirm New PIN:</label><input id='input_cpin' type='password' name='cpin' maxlength='4' inputmode='numeric' pattern='[0-9]*' required></div>"
        echo "<div class='float-right'><button type='submit' >CHANGE PIN</button></div>"
      	cencel_button                
	echo "</form>"
	
    fi

}

#Method for menu
menu(){ 

    echo "<form action='/ATM_Project/atm.sh' method='POST'>"
       
    if [[ "$pin" == "$rpin" ]]; then

       	#Menu options    
        option=$(echo "$QUERY_STRING" | sed -n 's/^.*option=\([^&]*\).*$/\1/p')
 
       	case "$option" in

      	    "bal")
	
	       	echo "<h2 class='style-txt'>Total account balance: Rs.${balance}</h2>"
                back_button
	      	;;

            "depo")
	
	      	deposite
	      	;;

	    "withd")
		
	      	withdraw
	      	;;
	
                
	    *)

                echo "<div class='top-section'><h3>Welcome back, Raushan</h3></div>"         
		echo "<input type='hidden' name='choice' value='login'>"                 
		echo "<input type='hidden' name='rpin' value='$pin'>"			
		echo "<div class='float-right'>"                
		echo "<button name='option' value='bal'>CHECK BALANCE</button>"      
		echo "<button name='option' value='depo'>DEPOSIT</button>"                 
		echo "<button name='option' value='withd'>GET CASH</button>"           
		echo "</div></form>"				
		cencel_button

        esac

    else

	echo "<form action='/ATM_Project/atm.sh' method='POST'>"
	echo "<div class='input-container'>"

        if [[ -n "$rpin" && "$pin" != "$rpin" ]]; then

	    echo "<p class='error'>Incorrect Pin!</p>"

	fi

        echo "<input type='hidden' name='choice' value='login'>"
        echo "<label for='input_pin'>Enter PIN:</label>"
	echo "<input id='input_pin' type='password' name='rpin' maxlength='4' inputmode='numeric' pattern='[0-9]*' required></div>"
        echo "<div class='float-right'><button type='submit' >LOGIN</button></div>"
	cencel_button
        echo "</form>"
		
    fi

}

#Method for deposite balance
deposite(){

    echo "<form action='/ATM_Project/atm.sh' method='POST'>"
    echo "<div class='input-container'>"

    #cheking entered amount is valid or not
    if [[ -n "$amt" && "$amt" -gt 0 ]]; then

	((balance += amt ))
	echo "<p class='sucess'>Rs.$amt credited to your account.<br> Total account balance is Rs.$balance.</p>"	          
       	back_button                 
	save_data
    else

        if [[ -n "$amt" && "$amt" -le 0 ]]; then

	    echo "<p class='error'>Please Enter Valid Amount.</p>"

	fi

	echo "<input type='hidden' name='choice' value='login'>"
	echo "<input type='hidden' name='rpin' value='$pin'>"            
    	echo "<input type='hidden' name='option' value='depo'>"          
  	echo "<label for='input_amt'>Enter Amount:</label>"
	echo "<input id='input_amt' type='text' inputmode='numeric' pattern='[0-9]*' required name='amt'></div>"	          
   	echo "<div class='float-right'><button type='submit'>DEPOSIT</button></div></form>"
        back_button
        echo "</form>"

    fi

}

#Method for Withdraw balance
withdraw(){

    echo "<form action='/ATM_Project/atm.sh' method='POST'>"
    echo "<div class='input-container'>"

    #checking entered amount is valid or not
    if [[ -n "$amt" && "$amt" -gt 0 && "$balance" -ge "$amt" ]]; then

	((balance -= amt ))
	echo "<p class='sucess' style='color: #FF5252;'>Rs.$amt is debited from your account.</p><p class='sucess'>Available account balance: Rs.$balance.</p>"      
       	back_button
	save_data

    elif [[ -n "$amt" && "$balance" -lt "$amt" ]]; then
	echo "<p class='error'>Insufficient Fund</p>"
	back_button
    else
	        
	if [[ -n "$amt" && "$amt" -le 0 ]]; then

	    echo "<p class='error'>Please Enter Valid Amount.</p>"
	
	fi

        echo "<input type='hidden' name='choice' value='login'>"
        echo "<input type='hidden' name='rpin' value='$pin'>"
        echo "<input type='hidden' name='option' value='withd'>"
        echo "<label for='input_amt'>Enter Amount:</label>"
	echo "<input id='input_amt' type='text' inputmode='numeric' pattern='[0-9]*' required name='amt'></div>"
        echo "<div class='float-right'><button type='submit'>GET CASH</button></div>"
        back_button
	echo"</form>"
       
    fi

}
       
echo "<form action='/ATM_Project/atm.sh' method='POST'>"

case "$choice" in

    "gen_pin")

	generate_pin
	;;

    "login")

        menu
        ;;

    "chan_pin")
	     
       	change_pin
	;;

    "cancel")
	echo "<div class='style-txt'><h2>Thanks for using ATM!</h2></div>"
	;;

    *)
			
        echo "<div class='top-section'><h1>:: Welcome to ATM ::</h1>"
	echo "<h3>Default Pin: ${pin}</h3></div>"
	echo "<div class='float-right'>"
        echo "<button name='choice' value='gen_pin'>GENERATE PIN</button>"
        echo "<button name='choice' value='login'>LOGIN</button>"
        echo "<button name='choice' value='chan_pin'>CHANGE PIN</button></div>"
        echo "<div class='float-left'><button name='choice' class='back-btn' value='cancel'>CANCEL</button></div>"
	echo "</form></body></html>"

esac
