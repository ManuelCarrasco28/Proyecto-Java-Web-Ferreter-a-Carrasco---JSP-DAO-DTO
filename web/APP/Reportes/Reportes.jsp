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

    // ================== PARÁMETROS DE FILTRO ==================
    String f1          = request.getParameter("desde");
    String f2          = request.getParameter("hasta");
    String tipo        = request.getParameter("tipo");        // T, V, C
    String clienteF    = request.getParameter("cliente");
    String proveedorF  = request.getParameter("proveedor");
    String metodoF     = request.getParameter("metodo");
    String montoMinStr = request.getParameter("montoMin");
    String montoMaxStr = request.getParameter("montoMax");

    if (tipo == null || tipo.isEmpty()) tipo = "T";   // T = Todos

    Double montoMin = null, montoMax = null;
    try { if (montoMinStr != null && !montoMinStr.isEmpty()) montoMin = Double.parseDouble(montoMinStr); } catch(Exception e){}
    try { if (montoMaxStr != null && !montoMaxStr.isEmpty()) montoMax = Double.parseDouble(montoMaxStr); } catch(Exception e){}

    // ============ NORMALIZAR FECHAS PARA APLICAR FILTRO OPCIONAL ============
    boolean aplicarFiltroFecha = false;
    if ((f1 != null && !f1.isEmpty()) || (f2 != null && !f2.isEmpty())) {
        aplicarFiltroFecha = true;
        if (f1 == null || f1.isEmpty()) f1 = f2;
        if (f2 == null || f2.isEmpty()) f2 = f1;
    }

    VentaDAO  vdao = new VentaDAO();
    CompraDAO cdao = new CompraDAO();

    // Listas base (solo con filtro de fecha)
    List<VentaDTO>  ventasBase;
    List<CompraDTO> comprasBase;

    if (aplicarFiltroFecha) {
        ventasBase  = vdao.listarVentasPorFecha(f1, f2);
        comprasBase = cdao.listarComprasPorFecha(f1, f2);
    } else {
        ventasBase  = vdao.listarVentas();
        comprasBase = cdao.listarCompras();
    }

    // ================== CONJUNTOS PARA COMBOS DINÁMICOS ==================
    Set<String> clientesSet    = new LinkedHashSet<>();
    Set<String> proveedoresSet = new LinkedHashSet<>();
    Set<String> metodosSet     = new LinkedHashSet<>();

    for (VentaDTO v : ventasBase) {
        if (v.getCliente() != null && !v.getCliente().isEmpty())
            clientesSet.add(v.getCliente());
        if (v.getMetodoPago() != null && !v.getMetodoPago().isEmpty())
            metodosSet.add(v.getMetodoPago());
    }
    for (CompraDTO c : comprasBase) {
        if (c.getProveedor() != null && !c.getProveedor().isEmpty())
            proveedoresSet.add(c.getProveedor());
        if (c.getMetodoPago() != null && !c.getMetodoPago().isEmpty())
            metodosSet.add(c.getMetodoPago());
    }

    // ================== APLICAR FILTROS EXTRA Y CALCULAR TOTALES ==================
    List<VentaDTO>  ventasFiltradas  = new ArrayList<>();
    List<CompraDTO> comprasFiltradas = new ArrayList<>();

    double totalVentasGlobal   = 0;
    double totalComprasGlobal  = 0;
    double totalVentasFilt     = 0;
    double totalComprasFilt    = 0;
    int    cantVentasFilt      = 0;
    int    cantComprasFilt     = 0;

    // Para gráfico de métodos de pago
    Map<String, Double> totMetodoMapa = new LinkedHashMap<>();

    // --- Ventas ---
    for (VentaDTO v : ventasBase) {
        totalVentasGlobal += v.getTotal();

        boolean ok = true;

        if (clienteF != null && !clienteF.isEmpty() && !"0".equals(clienteF)) {
            if (!clienteF.equals(v.getCliente())) ok = false;
        }
        if (metodoF != null && !metodoF.isEmpty() && !"0".equals(metodoF)) {
            if (!metodoF.equals(v.getMetodoPago())) ok = false;
        }
        if (montoMin != null && v.getTotal() < montoMin) ok = false;
        if (montoMax != null && v.getTotal() > montoMax) ok = false;

        if (ok) {
            ventasFiltradas.add(v);
            totalVentasFilt += v.getTotal();
            cantVentasFilt++;

            // acumular por método
            String key = (v.getMetodoPago() == null ? "N/A" : v.getMetodoPago());
            totMetodoMapa.put(key, totMetodoMapa.getOrDefault(key, 0.0) + v.getTotal());
        }
    }

    // --- Compras ---
    for (CompraDTO c : comprasBase) {
        totalComprasGlobal += c.getTotal();

        boolean ok = true;

        if (proveedorF != null && !proveedorF.isEmpty() && !"0".equals(proveedorF)) {
            if (!proveedorF.equals(c.getProveedor())) ok = false;
        }
        if (metodoF != null && !metodoF.isEmpty() && !"0".equals(metodoF)) {
            if (!metodoF.equals(c.getMetodoPago())) ok = false;
        }
        if (montoMin != null && c.getTotal() < montoMin) ok = false;
        if (montoMax != null && c.getTotal() > montoMax) ok = false;

        if (ok) {
            comprasFiltradas.add(c);
            totalComprasFilt += c.getTotal();
            cantComprasFilt++;

            String key = (c.getMetodoPago() == null ? "N/A" : c.getMetodoPago());
            totMetodoMapa.put(key, totMetodoMapa.getOrDefault(key, 0.0) + c.getTotal());
        }
    }

%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reportes - Ventas y Compras</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        .main-content {
            margin-left: 260px;
            padding: 25px;
            min-height: 100vh;
            background: #f8f9fa;
        }

        .section-header {
            font-weight: 600;
            padding: 10px 15px;
            color: #fff;
            border-radius: 4px 4px 0 0;
        }

        .bg-azul   { background: #0d6efd; }
        .bg-verde  { background: #198754; }
        .bg-morado { background: #6f42c1; }

        .table thead th {
            background: #212529;
            color: #fff;
            font-weight: 500;
        }

        .cards-resumen .card {
            border-left: 4px solid #0d6efd;
        }
    </style>
</head>
<body>

<%@ include file="../Layouts/sidebar.jsp" %>

<div class="main-content">

    <h3 class="mb-4">📊 Reportes de Ventas y Compras</h3>

    <!-- ================== FILTRO DE FECHAS Y CAMPOS ================== -->
    <div class="card shadow-sm mb-4">
        <div class="section-header bg-azul">Filtro de Fechas y Datos</div>
        <div class="card-body">
            <form method="get" class="row g-3">

                <div class="col-md-3">
                    <label class="form-label">Desde</label>
                    <input type="date" name="desde" class="form-control"
                           value="<%= (f1 != null ? f1 : "") %>">
                </div>

                <div class="col-md-3">
                    <label class="form-label">Hasta</label>
                    <input type="date" name="hasta" class="form-control"
                           value="<%= (f2 != null ? f2 : "") %>">
                </div>

                <div class="col-md-3">
                    <label class="form-label">Tipo</label>
                    <select name="tipo" class="form-select">
                        <option value="T" <%= "T".equals(tipo) ? "selected" : "" %>>Ventas y Compras</option>
                        <option value="V" <%= "V".equals(tipo) ? "selected" : "" %>>Solo Ventas</option>
                        <option value="C" <%= "C".equals(tipo) ? "selected" : "" %>>Solo Compras</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Método de pago</label>
                    <select name="metodo" class="form-select">
                        <option value="0">Todos</option>
                        <%
                            for (String m : metodosSet) {
                        %>
                            <option value="<%=m%>" <%= (m.equals(metodoF) ? "selected": "") %>><%=m%></option>
                        <%
                            }
                        %>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Cliente</label>
                    <select name="cliente" class="form-select">
                        <option value="0">Todos</option>
                        <%
                            for (String c : clientesSet) {
                        %>
                            <option value="<%=c%>" <%= (c.equals(clienteF) ? "selected": "") %>><%=c%></option>
                        <%
                            }
                        %>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Proveedor</label>
                    <select name="proveedor" class="form-select">
                        <option value="0">Todos</option>
                        <%
                            for (String p : proveedoresSet) {
                        %>
                            <option value="<%=p%>" <%= (p.equals(proveedorF) ? "selected": "") %>><%=p%></option>
                        <%
                            }
                        %>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Monto mínimo (S/)</label>
                    <input type="number" step="0.01" name="montoMin" class="form-control"
                           value="<%= (montoMinStr != null ? montoMinStr : "") %>">
                </div>

                <div class="col-md-3">
                    <label class="form-label">Monto máximo (S/)</label>
                    <input type="number" step="0.01" name="montoMax" class="form-control"
                           value="<%= (montoMaxStr != null ? montoMaxStr : "") %>">
                </div>

                <div class="col-md-4 d-flex align-items-end">
                    <button class="btn btn-primary w-100">Aplicar filtro</button>
                </div>

            </form>

            <div class="mt-3 d-flex gap-2">
                <!-- Exportar Excel -->
                <form method="get" action="ReportesExcel.jsp">
                    <input type="hidden" name="desde"     value="<%= (f1 != null ? f1 : "") %>">
                    <input type="hidden" name="hasta"     value="<%= (f2 != null ? f2 : "") %>">
                    <input type="hidden" name="tipo"      value="<%= tipo %>">
                    <input type="hidden" name="cliente"   value="<%= (clienteF   != null ? clienteF   : "") %>">
                    <input type="hidden" name="proveedor" value="<%= (proveedorF != null ? proveedorF : "") %>">
                    <input type="hidden" name="metodo"    value="<%= (metodoF    != null ? metodoF    : "") %>">
                    <input type="hidden" name="montoMin"  value="<%= (montoMinStr != null ? montoMinStr : "") %>">
                    <input type="hidden" name="montoMax"  value="<%= (montoMaxStr != null ? montoMaxStr : "") %>">
                    <button class="btn btn-success">📥 Exportar Excel</button>
                </form>

                <!-- Exportar PDF (vista para imprimir) -->
                <form method="get" action="ReportesPDF.jsp" target="_blank">
                    <input type="hidden" name="desde"     value="<%= (f1 != null ? f1 : "") %>">
                    <input type="hidden" name="hasta"     value="<%= (f2 != null ? f2 : "") %>">
                    <input type="hidden" name="tipo"      value="<%= tipo %>">
                    <input type="hidden" name="cliente"   value="<%= (clienteF   != null ? clienteF   : "") %>">
                    <input type="hidden" name="proveedor" value="<%= (proveedorF != null ? proveedorF : "") %>">
                    <input type="hidden" name="metodo"    value="<%= (metodoF    != null ? metodoF    : "") %>">
                    <input type="hidden" name="montoMin"  value="<%= (montoMinStr != null ? montoMinStr : "") %>">
                    <input type="hidden" name="montoMax"  value="<%= (montoMaxStr != null ? montoMaxStr : "") %>">
                    <button class="btn btn-outline-danger">🧾 Vista PDF</button>
                </form>
            </div>

            <small class="text-muted d-block mt-2">
                Si no ingresas fechas se mostrarán <strong>todas</strong> las ventas y compras.
                Si ingresas solo una fecha, se usará como inicio y fin del rango.
            </small>
        </div>
    </div>

    <!-- ================== TARJETAS RESUMEN ================== -->
    <div class="row mb-4 cards-resumen">
        <div class="col-md-3">
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <h6 class="text-muted mb-1">Total Ventas (global)</h6>
                    <h4>S/ <%= String.format("%.2f", totalVentasGlobal) %></h4>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <h6 class="text-muted mb-1">Ventas filtradas</h6>
                    <h4>S/ <%= String.format("%.2f", totalVentasFilt) %></h4>
                    <small class="text-muted"><%= cantVentasFilt %> registro(s)</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <h6 class="text-muted mb-1">Total Compras (global)</h6>
                    <h4>S/ <%= String.format("%.2f", totalComprasGlobal) %></h4>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <h6 class="text-muted mb-1">Compras filtradas</h6>
                    <h4>S/ <%= String.format("%.2f", totalComprasFilt) %></h4>
                    <small class="text-muted"><%= cantComprasFilt %> registro(s)</small>
                </div>
            </div>
        </div>
    </div>

    <!-- ================== VENTAS ================== -->
    <% if (!"C".equals(tipo)) { %>
    <div class="card shadow-sm mb-4">
        <div class="section-header bg-verde">🧾 Ventas Registradas</div>

        <div class="table-responsive">
            <table class="table table-striped align-middle mb-0">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Cliente</th>
                    <th>Registrado por</th>
                    <th>Método de Pago</th>
                    <th>Fecha</th>
                    <th>Total (S/)</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (ventasFiltradas.isEmpty()) {
                %>
                    <tr>
                        <td colspan="6" class="text-center text-muted py-3">
                            No hay registros de ventas para mostrar.
                        </td>
                    </tr>
                <%
                    } else {
                        for (VentaDTO v : ventasFiltradas) {
                %>
                    <tr>
                        <td><%= v.getIdTransaccion() %></td>
                        <td><%= v.getCliente() %></td>
                        <td><%= v.getUsuario() %></td>
                        <td><%= v.getMetodoPago() %></td>
                        <td><%= v.getFecha() %></td>
                        <td>S/ <%= String.format("%.2f", v.getTotal()) %></td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>

    <!-- ================== COMPRAS ================== -->
    <% if (!"V".equals(tipo)) { %>
    <div class="card shadow-sm">
        <div class="section-header bg-morado">📦 Compras Registradas</div>

        <div class="table-responsive">
            <table class="table table-striped align-middle mb-0">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Proveedor</th>
                    <th>Método de Pago</th>
                    <th>Fecha</th>
                    <th>Total (S/)</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (comprasFiltradas.isEmpty()) {
                %>
                    <tr>
                        <td colspan="5" class="text-center text-muted py-3">
                            No hay registros de compras para mostrar.
                        </td>
                    </tr>
                <%
                    } else {
                        for (CompraDTO c : comprasFiltradas) {
                %>
                    <tr>
                        <td><%= c.getIdTransaccion() %></td>
                        <td><%= c.getProveedor() %></td>
                        <td><%= c.getMetodoPago() %></td>
                        <td><%= c.getFecha() %></td>
                        <td>S/ <%= String.format("%.2f", c.getTotal()) %></td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>

    <!-- ================== GRÁFICOS ================== -->
    <div class="row mt-4">
        <div class="col-md-6 mb-4">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h6 class="mb-3">Ventas vs Compras (filtradas)</h6>
                    <canvas id="chartVC"></canvas>
                </div>
            </div>
        </div>

        <div class="col-md-6 mb-4">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h6 class="mb-3">Totales por método de pago</h6>
                    <canvas id="chartMetodo"></canvas>
                </div>
            </div>
        </div>
    </div>

</div>

<script>
    // --------- Datos desde JSP para JS ----------
    const totalVentasJS  = <%= String.format(Locale.US, "%.2f", totalVentasFilt) %>;
    const totalComprasJS = <%= String.format(Locale.US, "%.2f", totalComprasFilt) %>;

    const metodoLabels = [
        <% 
            int idx = 0;
            for (String k : totMetodoMapa.keySet()) {
                if (idx++ > 0) out.print(",");
        %>"<%=k%>"<% } %>
    ];

    const metodoData = [
        <%
            idx = 0;
            for (Double val : totMetodoMapa.values()) {
                if (idx++ > 0) out.print(",");
                out.print(String.format(Locale.US, "%.2f", val));
            }
        %>
    ];

    // --------- Gráfico Ventas vs Compras ---------
    const ctxVC = document.getElementById('chartVC').getContext('2d');
    new Chart(ctxVC, {
        type: 'bar',
        data: {
            labels: ['Ventas', 'Compras'],
            datasets: [{
                label: 'Total (S/)',
                data: [totalVentasJS, totalComprasJS]
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });

    // --------- Gráfico por método de pago ---------
    const ctxM = document.getElementById('chartMetodo').getContext('2d');
    new Chart(ctxM, {
        type: 'pie',
        data: {
            labels: metodoLabels,
            datasets: [{
                data: metodoData
            }]
        },
        options: { responsive: true }
    });
</script>

</body>
</html>










