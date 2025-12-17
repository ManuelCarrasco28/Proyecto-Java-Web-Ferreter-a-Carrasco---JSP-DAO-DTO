<%@ page import="java.util.Arrays" %>
<%
    String usuarioActual = (String) session.getAttribute("usuario");
    String rolActual = (String) session.getAttribute("rol");

    if (usuarioActual == null || rolActual == null) {
        response.sendRedirect(request.getContextPath() + "/APP/Usuarios/Usuarios_Login.jsp");
        return;
    }

    String rolesPermitidos = (String) request.getAttribute("rolesPermitidos");
    boolean accesoPermitido = true;

    if (rolesPermitidos != null && !rolesPermitidos.trim().isEmpty()) {
        accesoPermitido = Arrays.asList(rolesPermitidos.split(",")).contains(rolActual);
    }

    if (!accesoPermitido) {
        response.sendRedirect(request.getContextPath() + "/APP/Usuarios/Usuarios_Login.jsp?forbidden=1");
        return;
    }
%>
