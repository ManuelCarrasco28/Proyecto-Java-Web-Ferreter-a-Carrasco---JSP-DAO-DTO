<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="DAO.PersonaDAO,DAO.ProductoDAO,DAO.CompraDAO,DAO.CategoriaDAO" %>

<%
request.setAttribute("rolesPermitidos", "Administrador");
%>
<%@ include file="../Auth/validarAcceso.jsp" %>

<%@ page import="DTO.PersonaDTO,DTO.ProductoDTO,DTO.DetalleCompraDTO,DTO.CategoriaDTO" %>

<%
    request.setCharacterEncoding("UTF-8");

    PersonaDAO pdao = new PersonaDAO();
    ProductoDAO prdao = new ProductoDAO();
    CompraDAO cdao = new CompraDAO();
    CategoriaDAO catdao = new CategoriaDAO();

    String accion = request.getParameter("accion");
    String mensaje = "";
    String toastColor = "#dc3545";

    // filtros proveedor
    String buscarProveedor = request.getParameter("buscarProveedor");
    if (buscarProveedor == null) buscarProveedor = "";

    // filtros producto
    String filtroCategoria = request.getParameter("filtroCategoria");
    String buscarProducto = request.getParameter("buscarProducto");
    if (buscarProducto == null) buscarProducto = "";

    // CARRITO COMPRA
    List<DetalleCompraDTO> carrito = (List<DetalleCompraDTO>) session.getAttribute("carritoCompra");
    if (carrito == null) carrito = new ArrayList<>();

    /* ===========================================
       ACCIONES
    ============================================ */

    if ("agregarDetalle".equals(accion)) {
        try {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));
            double precio = Double.parseDouble(request.getParameter("precio"));

            ProductoDTO prod = prdao.obtenerPorId(idProducto);

            if (prod != null) {
                DetalleCompraDTO det = new DetalleCompraDTO();
                det.setIdProducto(idProducto);
                det.setNombreProducto(prod.getNombreProducto());
                det.setCantidad(cantidad);
                det.setPrecioUnitario(precio);

                carrito.add(det);

                mensaje = "Producto agregado al carrito";
                toastColor = "#0dcaf0"; // celeste

            } else {
                mensaje = "Producto no encontrado";
                toastColor = "#dc3545";
            }

        } catch (Exception e) {
            mensaje = "Error al agregar detalle";
            toastColor = "#dc3545";
        }

    } else if ("quitarDetalle".equals(accion)) {

        try {
            int index = Integer.parseInt(request.getParameter("index"));
            if (index >= 0 && index < carrito.size()) {
                carrito.remove(index);
                mensaje = "Producto quitado";
                toastColor = "#ffc107"; // amarillo
            }
        } catch (Exception e) {
            mensaje = "Error al quitar";
            toastColor = "#dc3545";
        }

    } else if ("confirmarCompra".equals(accion)) {

        try {
            int idProveedor = Integer.parseInt(request.getParameter("idProveedor"));
            String metodoPago = request.getParameter("metodoPago");

            int idUsuario = 1;
            if (session.getAttribute("idUsuario") != null)
                idUsuario = (int) session.getAttribute("idUsuario");

            double total = 0;
            for (DetalleCompraDTO d : carrito) total += d.getSubtotal();

            if (carrito.isEmpty()) {
                mensaje = "Debe agregar productos a la compra";
                toastColor = "#dc3545";
            } else if (idProveedor == 0) {
                mensaje = "Debe seleccionar un proveedor";
                toastColor = "#dc3545";
            } else {

                boolean ok = cdao.registrarCompra(
                        idProveedor,
                        idUsuario,
                        metodoPago,
                        total,
                        carrito
                );

                if (ok) {
                    carrito.clear();
                    mensaje = "Compra registrada correctamente";
                    toastColor = "#28a745"; // verde
                } else {
                    mensaje = "Error registrando compra";
                    toastColor = "#dc3545";
                }
            }

        } catch (Exception e) {
            mensaje = "Error confirmar compra";
            toastColor = "#dc3545";
        }
    }

    session.setAttribute("carritoCompra", carrito);

    // Cargar proveedores (tipo 3)
    List<PersonaDTO> proveedores;
    if (!buscarProveedor.trim().isEmpty()) {
        proveedores = pdao.listarProveedores(buscarProveedor.trim());
    } else {
        proveedores = pdao.listarPorTipo(3);
    }

    // categorías
    List<CategoriaDTO> categorias = catdao.listar("");

    Integer idCatFiltro = null;
    if (filtroCategoria != null && !filtroCategoria.equals("0") && !filtroCategoria.equals("")) {
        idCatFiltro = Integer.parseInt(filtroCategoria);
    }

    List<ProductoDTO> productos = prdao.listarActivosFiltrado(idCatFiltro, buscarProducto);

    double totalCompra = 0;
    for (DetalleCompraDTO d : carrito) totalCompra += d.getSubtotal();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Registro de Compras</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .main-content {
            margin-left: 260px;
            padding: 25px;
        }
        .section-header {
            padding: 8px 15px;
            color: #fff;
            font-weight: 600;
            border-radius: 4px 4px 0 0;
        }
        .section-body {
            border: 1px solid #e0e0e0;
            border-top: none;
            padding: 15px;
            border-radius: 0 0 4px 4px;
            background: #ffffff;
        }
        .bg-azul { background: #0d6efd; }
        .bg-verde { background: #198754; }
        .bg-gris { background: #6c757d; }

        /* --- Toast Moderno --- */
        .toast-container {
            position: fixed;
            bottom: 20px;
            left: 20px;
            z-index: 3000;
        }

        .toast-custom {
            background: #28a745;
            color: white;
            padding: 14px 22px;
            border-radius: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
            font-size: 15px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.25);
            transition: opacity .4s ease;
        }

        .toast-close-btn {
            background: rgba(255,255,255,0.25);
            border: none;
            color: white;
            font-size: 18px;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            pointer-events: auto;
        }

        .toast-close-btn:hover {
            background: rgba(255,255,255,0.40);
        }
    </style>
</head>

<body>

<%@ include file="../Layouts/sidebar.jsp" %>

<div class="main-content">

    <h4>📦 Registro de Compras</h4>

    <% if (!mensaje.equals("")) { %>
    <div class="toast-container" id="toastContainer">
        <div class="toast-custom" id="toastMsg" style="background:<%=toastColor%>;">
            <span><%=mensaje%></span>
            <button class="toast-close-btn" onclick="cerrarToast()">&times;</button>
        </div>
    </div>
    <% } %>

    <!-- ================== PROVEEDOR ================== -->
    <div class="mb-3">
        <div class="section-header bg-azul">📋 Datos del Proveedor</div>
        <div class="section-body">

            <form method="get" class="row g-2 mb-3">
                <div class="col-md-8">
                    <input type="text" name="buscarProveedor" class="form-control"
                           placeholder="Buscar por Razón Social o RUC..."
                           value="<%=buscarProveedor%>">
                </div>
                <div class="col-md-4">
                    <button class="btn btn-primary w-100">Buscar proveedor</button>
                </div>
            </form>

            <form class="row g-3">
                <div class="col-md-6">
                    <label>Proveedor</label>
                    <select name="idProveedor" class="form-select" form="formCompra" required>
                        <option value="0">Seleccione proveedor...</option>

                        <% for (PersonaDTO pv : proveedores) { %>
                            <option value="<%=pv.getIdPersona()%>">
                                <%=pv.getRazonSocial()%> (RUC: <%=pv.getRuc()%>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-3">
                    <label>Fecha</label>
                    <input type="date" disabled class="form-control"
                           value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                </div>

                <div class="col-md-3">
                    <label>Método Pago</label>
                    <select name="metodoPago" class="form-select" form="formCompra">
                        <option value="Efectivo">Efectivo</option>
                        <option value="Transferencia">Transferencia</option>
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
                        <% for (CategoriaDTO c : categorias) { %>
                            <option value="<%=c.getIdCategoria()%>"
                                <%= (idCatFiltro!=null && idCatFiltro==c.getIdCategoria())?"selected":"" %>>
                                <%=c.getNombreCategoria()%>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-5">
                    <label>Buscar producto</label>
                    <input type="text" name="buscarProducto" class="form-control"
                           placeholder="Nombre..."
                           value="<%=buscarProducto%>">
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

                <div class="col-md-3">
                    <label>Precio Compra (S/)</label>
                    <input type="number" step="0.01" name="precio" class="form-control" required>
                </div>

                <div class="col-md-2 d-flex align-items-end">
                    <button class="btn btn-success w-100">Agregar</button>
                </div>
            </form>

        </div>
    </div>

    <!-- ================== DETALLE COMPRA ================== -->
    <div class="mb-3">
        <div class="section-header bg-gris">📑 Detalle de Compra</div>

        <div class="section-body">
            <table class="table table-striped">
                <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Precio</th>
                    <th>Subtotal</th>
                    <th></th>
                </tr>
                </thead>

                <tbody>
                <%
                    int i=0;
                    for (DetalleCompraDTO d : carrito) {
                %>
                <tr>
                    <td><%=i+1%></td>
                    <td><%=d.getNombreProducto()%></td>
                    <td><%=d.getCantidad()%></td>
                    <td>S/ <%=d.getPrecioUnitario()%></td>
                    <td>S/ <%=d.getSubtotal()%></td>
                    <td>
                        <form method="post">
                            <input type="hidden" name="accion" value="quitarDetalle">
                            <input type="hidden" name="index" value="<%=i%>">
                            <button class="btn btn-sm btn-outline-danger">Quitar</button>
                        </form>
                    </td>
                </tr>
                <%
                        i++;
                    }

                    if (carrito.isEmpty()) {
                %>
                    <tr><td colspan="6" class="text-center text-muted">No hay productos</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ================== TOTAL ================== -->
    <div class="d-flex justify-content-between align-items-center mt-3">
        <h5>Total Compra: S/ <%=String.format("%.2f",totalCompra)%></h5>

        <form method="post" id="formCompra">
            <input type="hidden" name="accion" value="confirmarCompra">
            <button class="btn btn-primary">Guardar Compra</button>
        </form>
    </div>

</div>

<script>
function cerrarToast() {
    const t = document.getElementById("toastMsg");
    const cont = document.getElementById("toastContainer");
    if (!t) return;
    t.style.opacity = "0";
    setTimeout(() => { if (cont) cont.remove(); }, 400);
}

setTimeout(cerrarToast, 4000);
</script>

</body>
</html>







