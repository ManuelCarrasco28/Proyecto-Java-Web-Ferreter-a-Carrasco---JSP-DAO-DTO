ï»¿<%@ page session="true" %>
<%@ page import="DAO.DashboardDAO, java.util.*" %>

<%
request.setAttribute("rolesPermitidos", "Administrador,Vendedor");
%>
<%@ include file="../Auth/validarAcceso.jsp" %>

<%
String usuario = (String) session.getAttribute("usuario");
String rol = (String) session.getAttribute("rol");

if (usuario == null) {
    response.sendRedirect("../Usuarios/Usuarios_Login.jsp");
    return;
}

DashboardDAO dash = new DashboardDAO();

double ventasDia = dash.ventasDelDia();
int stockBajo = dash.productosStockBajo();
int nuevosClientes = dash.clientesNuevos();

List<Double> ventasMes = dash.ventasMensuales();
List<Double> comprasMes = dash.comprasMensuales();
List<String[]> topProductos = dash.productosMasVendidos(5);
List<String[]> productosBajo = dash.listarStockBajo(5);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">

<!-- CSS GLOBAL -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">


<!-- ChartJS -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ====== CONTENIDO GENERAL ====== */
body {
    background: #f4f6f9;
    margin: 0;
    font-family: Arial, sans-serif;
}

.main-content {
    margin-left: 260px; /* Espacio del sidebar */
    padding: 25px;
}

.titulo {
    font-size: 28px;
    font-weight: bold;
    margin-bottom: 25px;
}
.header-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;
}
.header-bar h3 { margin: 0; }
.bienvenida {
    text-align: right;
    color: #444;
    font-size: 14px;
}

/* ===== CARDS ===== */
.cards {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 25px;
}

.card {
    background: white;
    padding: 20px;
    border-radius: 14px;
    box-shadow: 0 4px 10px rgba(0,0,0,.08);
}

.card h3 {
    margin: 0;
    font-size: 17px;
}

.card p {
    margin-top: 10px;
    font-size: 28px;
}

/* ===== GRAFICOS ===== */
.chart-box {
    background: white;
    margin-top: 25px;
    padding: 20px;
    border-radius: 14px;
    box-shadow: 0 4px 10px rgba(0,0,0,.1);
}

.two-column {
    display: grid;
    grid-template-columns: 1.6fr 1fr;
    gap: 16px;
    margin-top: 20px;
}

.table-box {
    background: white;
    padding: 16px;
    border-radius: 14px;
    box-shadow: 0 4px 10px rgba(0,0,0,.1);
}

.table-box table { width: 100%; border-collapse: collapse; }
.table-box th, .table-box td { padding: 10px; text-align: left; border-bottom: 1px solid #e6e6e6; }
.table-box th { color: #555; font-size: 14px; }
.table-box td { color: #222; font-size: 14px; }

.chart-box canvas, .table-box canvas { width: 100% !important; max-height: 320px; }
</style>
</head>

<body>

<!-- SIDEBAR -->
<%@ include file="../Layouts/sidebar.jsp" %>

<!-- CONTENIDO CENTRAL -->
<div class="main-content">

    <div class="header-bar">
        <h2>Panel Principal</h2>
    </div>

    <!-- CARDS -->
    <div class="cards">

        <div class="card">
            <h3>Ventas del dia</h3>
            <p style="color:#008000;">S/ <%= ventasDia %></p>
        </div>

        <div class="card"><h3>Productos con stock bajo</h3><p style="color:#cc9900;"><%= stockBajo %></p><small style="color:#777;">Stock bajo: detalle al lado</small></div>

        <div class="card">
            <h3>Clientes nuevos</h3>
            <p style="color:#0066ff;"><%= nuevosClientes %></p>
        </div>

    </div>

        <div class="two-column">
        <div class="chart-box">
            <h3>Compras y ventas mensuales</h3>
            <canvas id="evolucionChart"></canvas>
        </div>

                <div class="table-box">
            <h3>Productos m&aacute;s vendidos</h3>
            <canvas id="topProductosChart"></canvas>
            <hr>
            <h4 style="margin-top:10px;">Stock bajo</h4>
            <ul style="list-style:none; padding-left:0; margin:0;">
            <%
                if (productosBajo != null && !productosBajo.isEmpty()) {
                    for (String[] sb : productosBajo) {
            %>
                <li style="display:flex; justify-content:space-between; padding:6px 0; border-bottom:1px solid #eee;">
                    <span><%= sb[0] %></span>
                    <span style="color:#cc9900; font-weight:700;">Stock: <%= sb[1] %></span>
                </li>
            <%
                    }
                } else {
            %>
                <li style="color:#777; text-align:center; padding:6px 0;">No hay productos con stock bajo.</li>
            <%
                }
            %>
            </ul>
        </div>
    </div>

</div>

<script>
new Chart(document.getElementById("evolucionChart"), {
    type: "line",
    data: {
        labels: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
        datasets: [
            {
                label: "Ventas",
                data: <%= ventasMes %>,
                borderColor: "#007bff",
                backgroundColor: "rgba(0,123,255,0.15)",
                borderWidth: 3,
                fill: true,
                tension: 0.3
            },
            {
                label: "Compras",
                data: <%= comprasMes %>,
                borderColor: "#28a745",
                backgroundColor: "rgba(40,167,69,0.15)",
                borderWidth: 3,
                fill: true,
                tension: 0.3
            }
        ]
    },
    options: {
        scales: { y: { beginAtZero: true } }
    }
});

const nombres = [<% if (topProductos != null) { for (int i=0;i<topProductos.size();i++){ String[] p=topProductos.get(i); %>"<%= p[0].replace("\"","\\\"") %>"<%= (i<topProductos.size()-1)?",":"" %><% } } %>];
const cantidades = [<% if (topProductos != null) { for (int i=0;i<topProductos.size();i++){ String[] p=topProductos.get(i); %><%= p[1] %><%= (i<topProductos.size()-1)?",":"" %><% } } %>];
const ctxPie = document.getElementById("topProductosChart");
if (ctxPie && cantidades.length) {
    new Chart(ctxPie, {
        type: 'pie',
        data: {
            labels: nombres,
            datasets: [{
                data: cantidades,
                backgroundColor: ['#007bff','#17a2b8','#ffc107','#28a745','#6610f2'],
                borderWidth: 1
            }]
        },
        options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
    });
}
</script>

</body>
</html>

































