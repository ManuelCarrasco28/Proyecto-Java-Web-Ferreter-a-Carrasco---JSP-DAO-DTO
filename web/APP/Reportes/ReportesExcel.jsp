<%@ page contentType="application/vnd.ms-excel;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="DAO.VentaDAO, DAO.CompraDAO" %>
<%@ page import="DTO.VentaDTO, DTO.CompraDTO" %>

<%
request.setAttribute("rolesPermitidos", "Administrador");
%>
<%@ include file="../Auth/validarAcceso.jsp" %>


<%
    request.setCharacterEncoding("UTF-8");

    String f1          = request.getParameter("desde");
    String f2          = request.getParameter("hasta");
    String tipo        = request.getParameter("tipo");
    String clienteF    = request.getParameter("cliente");
    String proveedorF  = request.getParameter("proveedor");
    String metodoF     = request.getParameter("metodo");
    String montoMinStr = request.getParameter("montoMin");
    String montoMaxStr = request.getParameter("montoMax");

    if (tipo == null || tipo.isEmpty()) tipo = "T";

    Double montoMin = null, montoMax = null;
    try { if (montoMinStr != null && !montoMinStr.isEmpty()) montoMin = Double.parseDouble(montoMinStr); } catch(Exception e){}
    try { if (montoMaxStr != null && !montoMaxStr.isEmpty()) montoMax = Double.parseDouble(montoMaxStr); } catch(Exception e){}

    boolean aplicarFiltroFecha = false;
    if ((f1 != null && !f1.isEmpty()) || (f2 != null && !f2.isEmpty())) {
        aplicarFiltroFecha = true;
        if (f1 == null || f1.isEmpty()) f1 = f2;
        if (f2 == null || f2.isEmpty()) f2 = f1;
    }

    VentaDAO  vdao = new VentaDAO();
    CompraDAO cdao = new CompraDAO();

    List<VentaDTO>  ventasBase;
    List<CompraDTO> comprasBase;

    if (aplicarFiltroFecha) {
        ventasBase  = vdao.listarVentasPorFecha(f1, f2);
        comprasBase = cdao.listarComprasPorFecha(f1, f2);
    } else {
        ventasBase  = vdao.listarVentas();
        comprasBase = cdao.listarCompras();
    }

    List<VentaDTO>  ventasFiltradas  = new ArrayList<>();
    List<CompraDTO> comprasFiltradas = new ArrayList<>();

    double totalVentasFilt  = 0;
    double totalComprasFilt = 0;

    for (VentaDTO v : ventasBase) {
        boolean ok = true;
        if (clienteF != null && !clienteF.isEmpty() && !"0".equals(clienteF) && !clienteF.equals(v.getCliente())) ok = false;
        if (metodoF  != null && !metodoF.isEmpty()  && !"0".equals(metodoF)  && !metodoF.equals(v.getMetodoPago())) ok = false;
        if (montoMin != null && v.getTotal() < montoMin) ok = false;
        if (montoMax != null && v.getTotal() > montoMax) ok = false;

        if (ok) {
            ventasFiltradas.add(v);
            totalVentasFilt += v.getTotal();
        }
    }

    for (CompraDTO c : comprasBase) {
        boolean ok = true;
        if (proveedorF != null && !proveedorF.isEmpty() && !"0".equals(proveedorF) && !proveedorF.equals(c.getProveedor())) ok = false;
        if (metodoF   != null && !metodoF.isEmpty()   && !"0".equals(metodoF)   && !metodoF.equals(c.getMetodoPago())) ok = false;
        if (montoMin  != null && c.getTotal() < montoMin) ok = false;
        if (montoMax  != null && c.getTotal() > montoMax) ok = false;

        if (ok) {
            comprasFiltradas.add(c);
            totalComprasFilt += c.getTotal();
        }
    }

    response.setHeader("Content-Disposition","attachment; filename=Reportes_"+System.currentTimeMillis()+".xls");
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Exportar Reportes</title>
</head>
<body>

<h3>Reporte de Ventas y Compras</h3>
<p>Rango de fechas:
    <strong><%= (f1 != null ? f1 : "Todas") %></strong> -
    <strong><%= (f2 != null ? f2 : "Todas") %></strong>
</p>

<% if (!"C".equals(tipo)) { %>
<h4>Ventas</h4>
<table border="1" cellpadding="4" cellspacing="0">
    <tr>
        <th>ID</th>
        <th>Cliente</th>
        <th>Usuario</th>
        <th>Método Pago</th>
        <th>Fecha</th>
        <th>Total (S/)</th>
    </tr>
    <%
        for (VentaDTO v : ventasFiltradas) {
    %>
    <tr>
        <td><%= v.getIdTransaccion() %></td>
        <td><%= v.getCliente() %></td>
        <td><%= v.getUsuario() %></td>
        <td><%= v.getMetodoPago() %></td>
        <td><%= v.getFecha() %></td>
        <td><%= String.format(Locale.US, "%.2f", v.getTotal()) %></td>
    </tr>
    <% } %>
    <tr>
        <td colspan="5"><strong>TOTAL</strong></td>
        <td><strong><%= String.format(Locale.US, "%.2f", totalVentasFilt) %></strong></td>
    </tr>
</table>
<br>
<% } %>

<% if (!"V".equals(tipo)) { %>
<h4>Compras</h4>
<table border="1" cellpadding="4" cellspacing="0">
    <tr>
        <th>ID</th>
        <th>Proveedor</th>
        <th>Método Pago</th>
        <th>Fecha</th>
        <th>Total (S/)</th>
    </tr>
    <%
        for (CompraDTO c : comprasFiltradas) {
    %>
    <tr>
        <td><%= c.getIdTransaccion() %></td>
        <td><%= c.getProveedor() %></td>
        <td><%= c.getMetodoPago() %></td>
        <td><%= c.getFecha() %></td>
        <td><%= String.format(Locale.US, "%.2f", c.getTotal()) %></td>
    </tr>
    <% } %>
    <tr>
        <td colspan="4"><strong>TOTAL</strong></td>
        <td><strong><%= String.format(Locale.US, "%.2f", totalComprasFilt) %></strong></td>
    </tr>
</table>
<% } %>

</body>
</html>

