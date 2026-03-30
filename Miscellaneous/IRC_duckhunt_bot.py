# Simple bot for IRC DuckHunt: https://github.com/theworm4002/IRC_DuckHunt

# Maybe you want to use NickServ if it is enabled: https://wiki.freenode.net/index.php?title=NickServ&oldid=298 

# It is configured to establish a reliable connection to irc.wechall.net #duckhunt, If you want to use it with other server comment the 'Wait for...' while loops and the 'PING-PONG' loop aswell.

# CHANGE THIS
config = {
    "host": "irc.wechall.net",
    "port": 6667,
    "nick": "abcd",
    "channel": "#duckhunt"
}

import socket, time, threading, random, os

duck_sounds = [
    "QUACK", "QUACK", "QUACK", "QUACK", "QUACK",
    "QUAC", "QUAC", "QUAAC", "QUAAC", "QUAAAC", "QUAAAC",
    "QUAK", "QUAK", "QUAAK", "QUAAK", "QUAAAK", "QUAAAK",
    "QWACK", "QWACK", "QWAACK", "QWAACK", "QWAAACK", "QWAAACK",
    "KWAK", "KWAK", "KWAAK", "KWAAK", "KWAAAK", "KWAAAK",
    "KWACK", "KWACK", "KWAACK", "KWAACK", "KWAAACK", "KWAAACK",
    "KAAK", "KAAK", "KAAAK", "KAAAK", "KAAAAK", "KAAAAK",
    "KAACK", "KAACK", "KAAACK", "KAAACK", "KAAAACK", "KAAAACK",
    "ARK", "ARK", "AARK", "AARK", "AAARK", "AAARK",
    "TWEET ?", "PEEP ?", "*whistle*", "Hello world",
    "I am here for the casting", "I hope no one will notice me", 
    "http://tinyurl.com/2qc9pl"
]

duck_leaves_the_chat_msg = [
        "duck escapes",
        "duck fled",
        "ducks fled",
        ]

reloading_warnings = [
        "Your gun is jammed, you must reload to unjam it",
        "JAMMED GUN",
        "EMPTY MAGAZINE",
        "Trigger locked",
        ]

class DuckHunter:
    def __init__(self, client):
        self.ducks_in_area = 0
        self.good_shots = 0
        self.running = False
        self.host = client['host']
        self.port = client['port']
        self.nick = client['nick']
        self.channel = client['channel']
        self.socket = None
        self.pong_id = ""

    def connect(self):
        # Establish TCP connection
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.connect((self.host, self.port))

        # Establish IRC connection
        self.socket.send(f"NICK {self.nick}\r\n".encode())
        self.socket.send(f"USER {self.nick} {self.nick} irc.wechall.net :{self.nick}\r\n".encode())
        res = ""

        # PING - PONG
        while "PING" not in res:
            res = self.recv_messages()
            print(res, end="")
        self.pong_id = res.split('PING')[1].split(':')[1].strip()
        self.socket.send(f"PONG :{self.pong_id}\r\n".encode())
        
        # Wait for the welcome banner
        while "wechall.net 001" not in res:
            res = self.recv_messages()
            print(res, end="")
        
        # Join to the channel
        self.socket.send(f"JOIN {self.channel}\r\n".encode())
        time.sleep(1)

        # Wait until it joins to the channel
        while "wechall.net 332" not in res and "#duckhunt" not in res:
            res = self.recv_messages() 
            print(res, end="")

        print(f"[+] Bot: Connected to {self.host}:{self.port} as {self.nick} in {self.channel}")

        self.running = True

    def recv_messages(self):
        res = ""
        while True:
            try: 
                self.socket.settimeout(2)
                res += self.socket.recv(1024).decode()
            except socket.timeout:
                break
            except Exception as e:
                print(f"[!] Bot: Error receiving: {e}")
                break
        return res

    def check_stats(self):
        while True:
            print("[+] Bot: Gathering game information.")
            try:
                self.socket.send(f"PRIVMSG {self.channel} :!duckstats {self.nick}\r\n".encode())
                self.socket.send(f"PRIVMSG {self.channel} :!lastduck\r\n".encode())
            except:
                pass
            time.sleep(random.randint(10,15) * 60)
    
    def process_messages(self, messages: str):
        for line in messages.splitlines():
            self.handle_ping(line)
            if f"PRIVMSG {self.channel}" in line:
                self.handle_channel_message(line)

    def handle_ping(self, line: str):
        if "PING" in line:
            self.socket.send(f"PONG :{self.pong_id}\r\n".encode())

    def handle_channel_message(self, line: str):
        self.detect_duck(line)
        self.update_duck_status(line)
        if f"{self.nick} >" in line:
            self.handle_bot_response(line)
          
    def detect_duck(self, line: str):
        for sound in duck_sounds:
            if sound in line and not "shot down" in line:
                print("[+] Bot: Duck detected, shooting!")
                self.ducks_in_area += 1
                self.socket.send(f"PRIVMSG {self.channel} :!bang\r\n".encode())
                return

    def update_duck_status(self, line: str):
        if self.ducks_in_area <= 0:
            return
        if self.other_player_killed_duck(line):
            print("[+] Bot: Duck killed by another player.")
            self.ducks_in_area -= 1
            return
        for msg in duck_leaves_the_chat_msg:
            if msg in line:
                print("[+] Bot: Duck missing.")
                self.ducks_in_area -= 1
                return

    def other_player_killed_duck(self, line: str):
        return (not f"{self.nick} >" in line and "*BANG*" in line and "You shot down" in line)

    def handle_bot_response(self, line: str):
        self.handle_shot_result(line)
        if self.need_to_reload(line):
            print("[+] Bot: Reloading!")
            self.socket.send(f"PRIVMSG {self.channel} :!reload\r\n".encode())
            print("[+] Bot: Shooting!")
            self.socket.send(f"PRIVMSG {self.channel} :!bang\r\n".encode())
        if "GUN CONFISCATED" in line:
            print("[!] Bot: Gun confiscated.")
            self.die()
        if "You have no ammo" in line:
            print("[!] Bot: No ammo.")
            self.die()
   
    def need_to_reload(self, line: str):
        for warn in reloading_warnings:
            if warn in line:
                return True
        return False

    def handle_shot_result(self, line: str):
        if self.ducks_in_area <= 0:
            return
        if "Missed" in line or f"{self.nick}'s bullet ricochetes on" in line:
            self.socket.send(f"PRIVMSG {self.channel} :!bang\r\n".encode())
        elif "*BANG*" in line and "You shot down" in line:
            print("[+] Bot: Duck killed.")
            self.good_shots += 1
            self.ducks_in_area -= 1

            if self.good_shots >= 3:
                self.buy_bread()
                self.good_shots = 0

    def buy_bread(self):
        print("[+] Bot: Good hunt! Buying bread.")
        for _ in range(random.randint(1, 2)):
            self.socket.send(f"PRIVMSG {self.channel} :!shop 21\r\n".encode())

    def die(self):
        self.running = False
        self.socket.close()
        os._exit(1)

    def play(self):
        # Check game status thread
        t = threading.Thread(target=self.check_stats)
        t.start()

        # Main logic
        while self.running:
            time.sleep(2)
            messages = self.recv_messages()
            if messages:
                print(messages,end="")
                # Interactions
                self.process_messages(messages)
def main():
    bot = DuckHunter(config)
    bot.connect()
    bot.play()

if __name__ == '__main__':
    main()
