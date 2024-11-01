import * as rc from "./rcon";

async function connect(ev) {
  ev.preventDefault();
  const form = ev.target as HTMLFormElement;
  try {
    form.output.value = "pending";
    await rc.connect(form.host.value, form.port.value, form.password.value);
    form.output.value = "connected";
  } catch (e) {
    form.output.value = e;
  }
}
async function renew(ev) {
  ev.preventDefault();
  const form = ev.target as HTMLFormElement;
  try {
    form.output.value = "pending";
    await rc.renew();
    form.output.value = "renewed";
  } catch (e) {
    form.output.value = e;
  }
}
async function disconnect(ev) {
  ev.preventDefault();
  const form = ev.target as HTMLFormElement;
  try {
    form.output.value = "pending";
    await rc.disconnect();
    form.output.value = "disconnected";
  } catch (e) {
    form.output.value = e;
  }
}
async function input(ev: SubmitEvent) {
  ev.preventDefault();
  const form = ev.target as HTMLFormElement;
  try {
    const data = await rc.input(form.payload.value);
    form.output.value = JSON.stringify(data, null, 2);
  } catch (e) {
    form.output.value = e;
  }
}
async function output(ev: SubmitEvent) {
  ev.preventDefault();
  const form = ev.target as HTMLFormElement;
  try {
    const data = await rc.output(form.payload.value);
    form.output.value = JSON.stringify(data, null, 2);
  } catch (e) {
    form.output.value = e;
  }
}
async function server(ev: SubmitEvent): Promise<void> {
  const action = ev.submitter?.id;
  if (action == "renew") renew(ev);
  else if (action == "disconnect") disconnect(ev);
  else connect(ev);
}

document.getElementById("server")?.addEventListener("submit", server);
document.getElementById("input")?.addEventListener("submit", input);
document.getElementById("output")?.addEventListener("submit", output);
