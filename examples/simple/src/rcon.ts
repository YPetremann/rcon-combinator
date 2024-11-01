export async function connect(host, port, password) {
  const res = await fetch("/connect", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ host, port, password }),
  });
  if (!res.ok) throw new Error(await res.text());
  localStorage.setItem("token", await res.text());
}
export async function renew() {
  const token = localStorage.getItem("token");
  const res = await fetch("/renew", {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error(await res.text());
  localStorage.setItem("token", await res.text());
}
export async function disconnect() {
  const token = localStorage.getItem("token");
  const res = await fetch("/disconnect", {
    headers: { Authorization: `Bearer ${token}` },
  });
  localStorage.removeItem("token");
  if (!res.ok) throw new Error(await res.text());
}
export async function input(body) {
  if (typeof body !== "string") body = JSON.stringify(body);
  const token = localStorage.getItem("token");
  const res = await fetch("/input", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body,
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json();
}
export async function output(body) {
  if (typeof body !== "string") body = JSON.stringify(body);
  const token = localStorage.getItem("token");
  const res = await fetch("/output", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body,
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json();
}
