import {Socket, LongPoller, Presence} from "phoenix"

class App {

  static init(){
    let userId = prompt("Enter a username", "browser")

    let socket = new Socket("/socket", {
      logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data) }),
      params: {user_id: userId, device_token: navigator.userAgent}
    })

    socket.connect()

    var $status    = $("#status")
    var $messages  = $("#messages")
    var $input     = $("#message-input")
    var $username  = $("#username")

    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    var chan = socket.channel("chat:lobby", {})
    chan.join().receive("ignore", () => console.log("auth error"))
               .receive("ok", () => console.log("join ok"))

    chan.onError(e => console.log("something went wrong", e))
    chan.onClose(e => console.log("channel closed", e))

    let presences = {}

    let formatTimestamp = (timestamp) => {
      let date = new Date(Number.parseInt(timestamp, 10))
      return date.toLocaleTimeString()
    }
    let listBy = (user, {metas: metas}) => {
      return {
        user: user,
        onlineAt: formatTimestamp(metas[0].online_at)
      }
    }

    let userList = document.getElementById("UserList")
    let render = (presences) => {
      userList.innerHTML = Presence.list(presences, listBy)
        .map(presence => `
          <li>
            ${presence.user}
            <br>
            <small>online since ${presence.onlineAt}</small>
          </li>
        `)
        .join("")
    }

    chan.on("presence_state", state => {
      presences = Presence.syncState(presences, state)
      render(presences)
    })

    chan.on("presence_diff", diff => {
      presences = Presence.syncDiff(presences, diff)
      render(presences)
    })

    $input.off("keypress").on("keypress", e => {
      if (e.keyCode == 13) {
        chan.push("new:msg", {body: $input.val()})
        $input.val("")
      }
    })

    chan.on("new:msg", msg => {
      $messages.append(this.messageTemplate(msg))
      scrollTo(0, document.body.scrollHeight)
    })

    chan.on("user:entered", msg => {
      var username = this.sanitize(msg.sender || "anonymous")
      $messages.append(`<br/><i>[${username} entered]</i>`)
    })
  }

  static sanitize(html){ return $("<div/>").text(html).html() }

  static messageTemplate(msg){
    let username = this.sanitize(msg.sender || "anonymous")
    let body     = this.sanitize(msg.body)

    return(`<p><a href='#'>[${username}]</a>&nbsp; ${body}</p>`)
  }

}

$( () => App.init() )

export default App
