// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
//import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

import cytoscape from 'cytoscape';
import cola from 'cytoscape-cola';

cytoscape.use( cola );


let Hooks = {}

function ScrollMe(){
  	console.log("im called")
    var doc = document.querySelector("#chatPage");
    console.log(doc)
    doc.scrollTop = doc.scrollHeight;
}
Hooks.Scroll = {
    mounted(){
    this.handleEvent("new_message", ({val}) => ScrollMe());
    }
};
Hooks.SendMsg= {
  mounted() {
    document.getElementById("textarea").addEventListener("keypress", (e) => {
            if (e.which === 13  && !event.shiftKey) {
                e.preventDefault()
                this.pushEvent("send_message", document.getElementById("textarea").value)
                document.getElementById("textarea").value=""
                 }
    }
    )

  }
}


Hooks.NodeChart= {
  mounted() {
    this.handleEvent("pushEventToJs", (payload) => {
    	console.log(" i am run")
    	console.log(payload["elements"])

  // var kk document.getElementById('cy') // container to render in


var cy = cytoscape({

  container: document.getElementById('cy'), // container to render in

  elements: payload["elements"],

  /*[ // list of graph elements to start with
    { // node a
      data: { id: 'a' }
    },
    { // node b
      data: { id: 'b' }
    },


    { // edge ab
      data: { id: 'ab', source: 'a', target: 'b' }
    }

  ],
  */

  style: [ // the stylesheet for the graph
    {
      selector: 'node',
      style: {
        'color' : 'black',
        'background-color': 'data(color)',

        'width': 'label',
        'height': '10px',
    		 // height: function(ele){ return Math.max(1, Math.ceil(ele.degree()/2)) * 10; },

        'padding': '2px',
        'shape': 'round-rectangle',
        'label': 'data(title)'
      }
    },

    {
      selector: 'edge',
      style: {
        'width': 1,
        'line-color': '#ccc',
        'target-arrow-color': '#ccc',
        'target-arrow-shape': 'triangle',
        'curve-style': 'bezier'
      }
    },
    {
      selector: 'label',
      style: {

        'text-halign': 'center',
        'font-size': '8px',
        'text-valign': 'center',
      }
    }


  ],

  layout: {
    name: 'cola'
    // rows: 1
  }

});


cy.on('tap', 'node', function(){
  try { // your browser may block popups
    window.open( this.data('href') );
  } catch(e){ // fall back on url change
    window.location.href = this.data('href');
  }
});



//cy.use(cola);

//cy.layout({ name: 'cola'})








  	})
  }

 }

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})


// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


// })


