<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reporte PDF - Ventas y Compras</title>
    <style>
        body { font-family: Arial, sans-serif; font-size: 12px; }
        h2, h3 { margin: 0; padding: 0; }
        .header { text-align: center; margin-bottom: 15px; }
        .info { font-size: 11px; margin-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 15px; }
        th, td { border: 1px solid #222; padding: 4px 6px; }
        th { background: #eee; }
        .tot { font-weight: bold; }
        @media print {
            button { display: none; }
        }
    </style>
</head>
<body>

<div class="header">
    <h2>CORPORACIÓN CARRASCO S.A.C.</h2>
    <h3>Reporte de Ventas y Compras</h3>
    <div class="info">
        Rango de fechas:
        <strong><%= (f1 != null ? f1 : "Todas") %></strong> -
        <strong><%= (f2 != null ? f2 : "Todas") %></strong>
        <br>
        Generado: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date()) %>
    </div>
</div>

<% if (!"C".equals(tipo)) { %>
<h4>Ventas</h4>
<table>
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
        <td colspan="5" class="tot">TOTAL</td>
        <td class="tot"><%= String.format(Locale.US, "%.2f", totalVentasFilt) %></td>
    </tr>
</table>
<% } %>

<% if (!"V".equals(tipo)) { %>
<h4>Compras</h4>
<table>
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
        <td colspan="4" class="tot">TOTAL</td>
        <td class="tot"><%= String.format(Locale.US, "%.2f", totalComprasFilt) %></td>
    </tr>
</table>
<% } %>

<button onclick="window.print()">Imprimir / Guardar como PDF</button>

</body>
</html>

