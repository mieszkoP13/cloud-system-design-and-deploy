const { createServer } = require("http");
const { Server } = require("socket.io");

const httpServer = createServer();
const io = new Server(httpServer, {
  cors: "http://localhost:5174/",
});

const allUsers = {};
const allRooms = [];

io.on("connection", (socket) => {
  allUsers[socket.id] = {
    socket: socket,
    online: true,
  };

  socket.on("request_to_play", (data) => {
    const currentUser = allUsers[socket.id];
    currentUser.playerName = data.playerName;

    let roomFound = false;

    // search for room where there is only one player
    for (let i = 0; i < allRooms.length; i++) {
      const room = allRooms[i];
      if (!room.player2) {
        room.player2 = currentUser;
        roomFound = true;

        currentUser.socket.emit("OpponentFound", {
          opponentName: room.player1.playerName,
          playingAs: "circle",
        });

        room.player1.socket.emit("OpponentFound", {
          opponentName: currentUser.playerName,
          playingAs: "cross",
        });

        currentUser.socket.on("playerMoveFromClient", (data) => {
          room.player1.socket.emit("playerMoveFromServer", {
            ...data,
          });
        });

        room.player1.socket.on("playerMoveFromClient", (data) => {
          currentUser.socket.emit("playerMoveFromServer", {
            ...data,
          });
        });

        break;
      }
    }

    // if such room not found, create new room
    if (!roomFound) {
      const newRoom = {
        player1: currentUser,
        player2: null,
      };
      allRooms.push(newRoom);
    }
  });

  socket.on("disconnect", function () {
    const currentUser = allUsers[socket.id];
    currentUser.online = false;
    currentUser.playing = false;

    for (let i = 0; i < allRooms.length; i++) {
      const room = allRooms[i];

      if (room.player1 && room.player1.socket.id === socket.id) {
        if (room.player2) {
          room.player2.socket.emit("opponentLeftMatch");
        }
        allRooms.splice(i, 1);
        break;
      }

      if (room.player2 && room.player2.socket.id === socket.id) {
        room.player1.socket.emit("opponentLeftMatch");
        allRooms.splice(i, 1);
        break;
      }
    }
  });
});

httpServer.listen(3000);
