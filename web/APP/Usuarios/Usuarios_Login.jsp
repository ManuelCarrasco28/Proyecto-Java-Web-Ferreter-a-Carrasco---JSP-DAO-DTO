<%@ page import="DAO.UsuarioDAO" %>
<%@ page import="DTO.UsuarioDTO" %>
<%
    String mensaje = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String user = request.getParameter("usuario");
        String clave = request.getParameter("clave");
        UsuarioDAO dao = new UsuarioDAO();
        UsuarioDTO u = dao.login(user, clave);
        if (u != null) {
            session.setAttribute("usuario", u.getUsuario());
            session.setAttribute("idUsuario", u.getIdUsuario());
            session.setAttribute("rol", u.getRol());
            String nombreCompleto = ((u.getNombres() != null ? u.getNombres() : "") + " " + (u.getApellidos() != null ? u.getApellidos() : "")).trim();
            session.setAttribute("nombreCompleto", nombreCompleto);
            response.sendRedirect("../Dashboard/Dashboard.jsp");
            return;
        } else {
            mensaje = "Usuario o contrasena incorrectos";
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Iniciar Sesion - Corporacion Carrasco</title>
    <style>
        body { margin:0; padding:0; font-family: Arial, sans-serif; background:#0056d6; display:flex; justify-content:center; align-items:center; height:100vh; }
        .card { background:white; padding:40px 45px; width:420px; border-radius:25px; text-align:center; box-shadow:0 10px 30px rgba(0,0,0,0.25); }
        .logo-img { width:110px; margin-bottom:15px; }
        h2 { margin:5px 0; font-size:24px; font-weight:bold; color:#0044b3; }
        .sub { font-size:14px; color:#555; margin-bottom:25px; }
        .input-group { text-align:left; margin-bottom:20px; position:relative; }
        label { display:block; font-weight:bold; margin-bottom:5px; font-size:15px; color:#222; }
        input { width:100%; padding:13px; border-radius:10px; border:1px solid #ccc; font-size:14px; color:#000; outline:none; }
        input::placeholder { color:rgba(0,0,0,0.38); }
        input:focus { border:1px solid #0a76d8; box-shadow:0 0 4px rgba(0,113,255,0.4); }
        .toggle-password { position:absolute; right:15px; top:39px; cursor:pointer; width:22px; height:22px; }
        button { margin-top:5px; width:100%; padding:14px; border:none; background:#0056d6; color:white; font-size:16px; border-radius:10px; cursor:pointer; transition:0.2s; }
        button:hover { background:#003fa3; }
        .msg { margin-top:12px; font-weight:bold; color:red; font-size:14px; }
        footer { margin-top:20px; font-size:12px; color:#777; }
    </style>
</head>
<body>
<div class="card">
    <img class="logo-img" src="${pageContext.request.contextPath}/resources/img/logo.png" alt="Logo">
    <h2>CORPORACION CARRASCO</h2>
    <p class="sub">Inicie sesion para continuar</p>
    <form method="post">
        <div class="input-group">
            <label>Usuario</label>
            <input type="text" name="usuario" placeholder="tucorreo@gmail.com" required>
        </div>
        <div class="input-group">
            <label>Contrasena</label>
            <input type="password" id="clave" name="clave" placeholder="**********" required>
            <svg id="icon-eye" class="toggle-password" onclick="togglePassword()" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#666"><path d="M12 5c-7.6 0-11 7-11 7s3.4 7 11 7 11-7 11-7-3.4-7-11-7zm0 12a5 5 0 1 1 0-10 5 5 0 0 1 0 10z"/></svg>
        </div>
        <button type="submit">Iniciar sesion</button>
    </form>
    <% if (!mensaje.equals("")) { %>
        <div class="msg"><%= mensaje %></div>
    <% } %>
    <footer>&copy; 2025 Corporacion Carrasco S.A.C.</footer>
</div>
<script>
function togglePassword() {
    var input = document.getElementById('clave');
    if (!input) return;
    input.type = (input.type === 'password') ? 'text' : 'password';
}
</script>
</body>
</html>
