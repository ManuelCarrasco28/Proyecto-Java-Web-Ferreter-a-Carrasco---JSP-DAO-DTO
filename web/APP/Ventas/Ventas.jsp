<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%
request.setAttribute("rolesPermitidos", "Administrador,Vendedor");
%>
<%@ include file="../Auth/validarAcceso.jsp" %>

<%@ page import="DAO.PersonaDAO,DAO.ProductoDAO,DAO.VentaDAO,DAO.CategoriaDAO" %>
<%@ page import="DTO.PersonaDTO,DTO.ProductoDTO,DTO.DetalleVentaDTO,DTO.CategoriaDTO" %>

<%
    request.setCharacterEncoding("UTF-8");

    PersonaDAO   pdao = new PersonaDAO();
    ProductoDAO  prdao = new ProductoDAO();
    VentaDAO     vdao  = new VentaDAO();
    CategoriaDAO cdao  = new CategoriaDAO();

    String accion     = request.getParameter("accion");
    String mensaje    = "";
    String toastColor = "#dc3545";

    String buscarCliente  = request.getParameter("buscarCliente");
    if (buscarCliente == null) buscarCliente = "";

    String filtroCategoria = request.getParameter("filtroCategoria");
    String buscarProducto  = request.getParameter("buscarProducto");
    if (buscarProducto == null) buscarProducto = "";

    List<DetalleVentaDTO> carrito = (List<DetalleVentaDTO>) session.getAttribute("carrito");
    if (carrito == null) carrito = new ArrayList<>();

    /* ============================================
       ACCIONES
    ============================================ */

    if ("agregarDetalle".equals(accion)) {
        try {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));
            int cantidad   = Integer.parseInt(request.getParameter("cantidad"));
            ProductoDTO prod = prdao.obtenerPorId(idProducto);

            if (prod != null) {
                if (cantidad <= prod.getStock()) {

                    boolean encontrado = false;

                    for (DetalleVentaDTO d : carrito) {
                        if (d.getIdProducto() == idProducto) {
                            int nuevaCant = d.getCantidad() + cantidad;

                            if (nuevaCant > prod.getStock()) {
                                mensaje    = "Stock insuficiente para el producto seleccionado";
                                toastColor = "#dc3545";
                            } else {
                                d.setCantidad(nuevaCant);
                                d.setSubtotal(nuevaCant * d.getPrecioUnitario());
                                mensaje    = "Cantidad actualizada en el carrito";
                                toastColor = "#0dcaf0";
                            }

                            encontrado = true;
                            break;
                        }
                    }

                    if (!encontrado) {
                        DetalleVentaDTO det = new DetalleVentaDTO();
                        det.setIdProducto(idProducto);
                        det.setNombreProducto(prod.getNombreProducto());
                        det.setCantidad(cantidad);
                        det.setPrecioUnitario(prod.getPrecioVenta());
                        det.setSubtotal(cantidad * prod.getPrecioVenta());
                        carrito.add(det);

                        mensaje    = "Producto agregado a la venta";
                        toastColor = "#0dcaf0";
                    }

                } else {
                    mensaje    = "Stock insuficiente para el producto seleccionado";
                    toastColor = "#dc3545";
                }

            } else {
                mensaje    = "Producto no encontrado";
                toastColor = "#dc3545";
            }

        } catch (Exception e) {
            mensaje    = "Error al agregar producto";
            toastColor = "#dc3545";
        }
    }
    else if ("quitarDetalle".equals(accion)) {

        try {
            int index = Integer.parseInt(request.getParameter("index"));
            if (index >= 0 && index < carrito.size()) {
                carrito.remove(index);
                mensaje    = "Producto quitado de la venta";
                toastColor = "#ffc107";
            }
        } catch (Exception e) {
            mensaje    = "Error al quitar producto";
            toastColor = "#dc3545";
        }

    }
    else if ("confirmarVenta".equals(accion)) {

        try {
            String idClienteStr = request.getParameter("idCliente");
            int idCliente = (idClienteStr != null && !idClienteStr.equals("")) ?
                            Integer.parseInt(idClienteStr) : 0;

            String metodoPago = request.getParameter("metodoPago");

            int idUsuario = 1;
            Object objIdUsuario = session.getAttribute("idUsuario");
            if (objIdUsuario instanceof Integer) idUsuario = (Integer) objIdUsuario;

            double total = 0;
            for (DetalleVentaDTO d : carrito) total += d.getSubtotal();

            if (carrito.isEmpty()) {
                mensaje    = "No hay productos en la venta";
                toastColor = "#dc3545";

            } else if (idCliente == 0) {
                mensaje    = "Debe seleccionar un cliente";
                toastColor = "#dc3545";

            } else {

                boolean ok = vdao.registrarVenta(
                        idCliente,
                        idUsuario,
                        metodoPago,
                        total,
                        carrito
                );

                if (ok) {
                    mensaje    = "Venta registrada correctamente";
                    toastColor = "#28a745";
                    carrito.clear();
                } else {
                    mensaje    = "Error registrando la venta (stock o BD)";
                    toastColor = "#dc3545";
                }
            }

        } catch (Exception e) {
            mensaje    = "Error al confirmar venta";
            toastColor = "#dc3545";
        }
    }

    session.setAttribute("carrito", carrito);

    /* ============================================
       CLIENTES + PRODUCTOS
    ============================================ */

    List<PersonaDTO> clientes;

    if (!buscarCliente.trim().isEmpty()) {
        clientes = pdao.listarClientes(buscarCliente.trim());
    } else {
        clientes = pdao.listarPorTipo(2);
    }

    List<CategoriaDTO> categorias = cdao.listar("");

    Integer idCatFiltro = null;
    if (filtroCategoria != null && !filtroCategoria.equals("") && !filtroCategoria.equals("0")) {
        try { idCatFiltro = Integer.parseInt(filtroCategoria); } catch (Exception e) {}
    }

    List<ProductoDTO> productos = prdao.listarActivosFiltrado(idCatFiltro, buscarProducto);

    double totalVenta = 0;
    for (DetalleVentaDTO d : carrito) totalVenta += d.getSubtotal();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Registro de Ventas</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .main-content { margin-left: 260px; padding: 25px; }
        .section-header { padding: 8px 15px; color: #fff; font-weight: 600; border-radius: 4px 4px 0 0; }
        .section-body { border: 1px solid #e0e0e0; border-top: none; padding: 15px; background: #fff; border-radius: 0 0 4px 4px; }
        .bg-azul  { background: #0d6efd; }
        .bg-verde { background: #198754; }
        .bg-gris  { background: #6c757d; }

        .toast-container { position: fixed; bottom: 20px; left: 20px; z-index: 3000; }
        .toast-custom { color: white; padding: 14px 22px; border-radius: 25px; font-size: 15px; display:flex; align-items:center; gap:15px; box-shadow:0 4px 10px rgba(0,0,0,0.25); transition:opacity .4s ease; }
        .toast-close-btn {
    background: rgba(255,255,255,0.25);
    border: none;
    color: white;
    font-size: 18px;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    pointer-events: auto;
}
        .toast-close-btn:hover { background:rgba(255,255,255,0.40); }
    </style>
</head>

<body>

<%@ include file="../Layouts/sidebar.jsp" %>

<div class="main-content">

    <h4>📦 Registro de Ventas</h4>

    <% if (!mensaje.equals("")) { %>
        <div class="toast-container" id="toastContainer">
            <div class="toast-custom" id="toastMsg" style="background:<%=toastColor%>;">
                <span><%=mensaje%></span>
                <button class="toast-close-btn" onclick="cerrarToast()">&times;</button>
            </div>
        </div>
    <% } %>

    <!-- ================== CLIENTE ================== -->
    <div class="mb-3">
        <div class="section-header bg-azul">📋 Datos del Cliente</div>

        <div class="section-body">

            <form method="get" class="row g-2 mb-3">
                <div class="col-md-8">
                    <input type="text" name="buscarCliente" class="form-control" placeholder="Buscar cliente por nombre o DNI..." value="<%=buscarCliente%>">
                </div>
                <div class="col-md-4">
                    <button class="btn btn-primary w-100">Buscar cliente</button>
                </div>
            </form>

            <form method="post" id="formVenta" class="row g-3">
                <input type="hidden" name="accion" value="confirmarVenta">

                <div class="col-md-6">
                    <label>Cliente</label>
                    <select name="idCliente" class="form-select" required>
                        <option value="0">Seleccione un cliente...</option>
                        <% for (PersonaDTO c : clientes) { %>
                            <option value="<%=c.getIdPersona()%>"><%=c.getNombres()%> <%=c.getApellidos()%></option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-3">
                    <label>Fecha</label>
                    <input type="text" class="form-control" disabled value="<%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %>">
                </div>

                <div class="col-md-3">
                    <label>Método de Pago</label>
                    <select name="metodoPago" class="form-select">
                        <option value="Efectivo">Efectivo</option>
                        <option value="Tarjeta">Tarjeta</option>
                        <option value="Yape/Plin">Yape/Plin</option>
                    </select>
                </div>
            </form>

        </div>
    </div>

    <!-- ================== PRODUCTOS ================== -->
    <div class="mb-3">
        <div class="section-header bg-verde">➕ Agregar Productos</div>

        <div class="section-body">

            <form method="get" class="row g-2 mb-3">
                <div class="col-md-4">
                    <label>Categoría</label>
                    <select name="filtroCategoria" class="form-select">
                        <option value="0">Todas</option>
                        <% for (CategoriaDTO cat : categorias) { %>
                            <option value="<%=cat.getIdCategoria()%>" <%= (idCatFiltro!=null && idCatFiltro==cat.getIdCategoria())?"selected":"" %>>
                                <%=cat.getNombreCategoria()%>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-5">
                    <label>Buscar producto</label>
                    <input type="text" name="buscarProducto" class="form-control" placeholder="Nombre..." value="<%=buscarProducto%>">
                </div>

                <div class="col-md-3 d-flex align-items-end">
                    <button class="btn btn-secondary w-100">Filtrar</button>
                </div>
            </form>

            <form method="post" class="row g-3">
                <input type="hidden" name="accion" value="agregarDetalle">

                <div class="col-md-5">
                    <label>Producto</label>
                    <select name="idProducto" class="form-select" required>
                        <option value="">Seleccione...</option>
                        <% for (ProductoDTO p : productos) { %>
                            <option value="<%=p.getIdProducto()%>">
                                <%=p.getNombreProducto()%> (Stock: <%=p.getStock()%>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-2">
                    <label>Cantidad</label>
                    <input type="number" name="cantidad" value="1" min="1" class="form-control">
                </div>

                <div class="col-md-3 d-flex align-items-end">
                    <button class="btn btn-success w-100">Agregar</button>
                </div>


            </form>
        </div>
    </div>

    <!-- ================== DETALLE DE VENTA ================== -->
    <div class="mb-3">
        <div class="section-header bg-gris">📑 Detalle de Venta</div>

        <div class="section-body">
            <table class="table table-striped">
                <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Precio Unitario</th>
                    <th>Subtotal</th>
                    <th></th>
                </tr>
                </thead>

                <tbody>
                <%
                    int index = 0;
                    for (DetalleVentaDTO d : carrito) {
                %>
                <tr>
                    <td><%=index+1%></td>
                    <td><%=d.getNombreProducto()%></td>
                    <td><%=d.getCantidad()%></td>
                    <td>S/ <%=String.format("%.2f",d.getPrecioUnitario())%></td>
                    <td>S/ <%=String.format("%.2f",d.getSubtotal())%></td>
                    <td>
                        <form method="post">
                            <input type="hidden" name="accion" value="quitarDetalle">
                            <input type="hidden" name="index" value="<%=index%>">
                            <button class="btn btn-sm btn-outline-danger">Quitar</button>
                        </form>
                    </td>
                </tr>
                <%
                        index++;
                    }
                    if (carrito.isEmpty()) {
                %>
                    <tr>
                        <td colspan="6" class="text-center text-muted">No hay productos agregados.</td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ================== TOTAL VENTA ================== -->
    <div class="d-flex justify-content-between align-items-center mt-3">
        <h5>Total Venta: S/ <%=String.format("%.2f",totalVenta)%></h5>

        <button class="btn btn-primary" form="formVenta">Confirmar Venta</button>
    </div>

</div>

<script>
function cerrarToast() {
    const t = document.getElementById("toastMsg");
    const c = document.getElementById("toastContainer");
    if (!t) return;
    t.style.opacity = "0";
    setTimeout(() => { if (c) c.remove(); }, 400);
}
setTimeout(cerrarToast, 4000);
</script>

</body>
</html>
