// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import Hooks from "./hooks/hooks";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

const toTransform = (x, y) => `translate(${x}px, ${y}px)`;

const lerp = (a, b, alpha) => {
  return a + alpha * (b - a);
};

const simulate = (bodies) => {
  const [screenWidth, screenHeight] = [
    window.innerWidth,
    window.scrollY + window.innerHeight,
  ];
  const target = document.querySelector("#background");

  for (let i = 0; i < 100; i++) {
    if (Math.random() >= 0.999) {
      offset = (screenWidth / 100) * i;

      const div = document.createElement("div");
      div.appendChild(document.createTextNode("@"));

      target.appendChild(div);
      div.style.transform = toTransform(offset, 0);
      div.style.position = "absolute";
      div.style.color = "rgba(255, 255, 255, 1)";
      bodies.push({
        body: div,
        delta: Math.random() * 1_000_000,
      });
    }
  }

  for (const element of bodies) {
    const { body, delta } = element;
    const [x, y] = body.style.transform
      .split("(")[1]
      .split(")")[0]
      .replace("px", "")
      .replace("px", "")
      .replace(" ", "")
      .split(",")
      .map((i) => {
        return Number(i);
      });

    body.style.transform = toTransform(
      x - Math.cos(delta * 0.01),
      y - Math.max(Math.abs(Math.cos(delta * 0.01)), 0.5),
    );

    element.delta += Math.random();

    [r, g, b, a] = body.style.color
      .replace("rgba", "")
      .replace("(", "")
      .replace(")", "")
      .split(",")
      .map(Number);

    const percentDone = Math.abs(y / screenHeight);

    body.style.color = `rgba(${lerp(255, 0, percentDone)}, 0, ${lerp(0, 255, percentDone)}, ${Math.max(1 - percentDone, 0.2)})`;

    if (percentDone > 1.1) {
      body.remove();
    }
  }

  requestAnimationFrame(() => {
    simulate(bodies);
  });
};

requestAnimationFrame(() => {
  simulate([], 0);
});
