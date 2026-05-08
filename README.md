<img width="1620" height="830" alt="ATM Project" src="https://github.com/user-attachments/assets/c02e3a1c-9dcd-4e56-8c31-6733d961ad05" />

# ATM Simulation System (Shell Script)

A web-based ATM simulation project built using Bash scripting and Apache CGI.

## Features
- Secure PIN login (Hidden input)
- Balance check and updates
- Responsive UI with background image
- Directory browsing protection

## How to Run
1. Install Apache2: `sudo apt install apache2`
2. Enable CGI: `sudo a2enmod cgi && sudo systemctl restart apache2`
3. Copy this folder to `/var/www/html/`
4. Give permissions: `sudo chmod -r 755 /var/www/html/ATM_Project`
5. Open in browser: `http://localhost/ATM_Project/atm.sh`
