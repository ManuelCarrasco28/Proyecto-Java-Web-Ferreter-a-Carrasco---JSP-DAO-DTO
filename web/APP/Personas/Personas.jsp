<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="DAO.PersonaDAO,DTO.PersonaDTO,java.util.*" %>
<%
request.setAttribute("rolesPermitidos", "Administrador,Vendedor");
%>
<%@ include file="../Auth/validarAcceso.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    PersonaDAO dao = new PersonaDAO();
    String buscar = request.getParameter("buscar");
    if (buscar == null) buscar = "";

    String accion = request.getParameter("accion");
    String mensaje = "";
    String toastColor = "#dc3545";

    /* ==== ACCIONES CRUD ==== */
    if ("guardar".equals(accion)) {
        String dni = request.getParameter("documento");
        String telefono = request.getParameter("telefono");
        String correo = request.getParameter("correo");

        if (dni == null || !dni.matches("[0-9]{8}")) {
            mensaje = "El DNI debe tener 8 dígitos numéricos";
        } else if (telefono != null && !telefono.isEmpty() && !telefono.matches("[0-9]{9}")) {
            mensaje = "El teléfono debe tener 9 dígitos numéricos";
        } else if (correo == null || !correo.contains("@")) {
            mensaje = "El correo debe contener @";
        } else if (dao.existeDocumento(dni, null)) {
            mensaje = "Ya existe un cliente con el mismo DNI";
        } else if (dao.existeCorreo(correo, null)) {
            mensaje = "Ya existe un cliente con el mismo correo";
        } else {
            PersonaDTO p = new PersonaDTO();
            p.setNombres(request.getParameter("nombres"));
            p.setApellidos(request.getParameter("apellidos"));
            p.setDocumento(dni);
            p.setTelefono(telefono);
            p.setCorreo(correo);
            p.setDireccion(request.getParameter("direccion"));
            p.setEstado(Integer.parseInt(request.getParameter("estado")));

            boolean ok = dao.registrar(p);
            mensaje = ok ? "Cliente registrado correctamente" : "Error registrando cliente";
            toastColor = ok ? "#0dcaf0" : "#dc3545";
        }

    } else if ("editar".equals(accion)) {

        int idPersona = Integer.parseInt(request.getParameter("idPersona"));
        String dni = request.getParameter("documento");
        String telefono = request.getParameter("telefono");
        String correo = request.getParameter("correo");

        if (dni == null || !dni.matches("[0-9]{8}")) {
            mensaje = "El DNI debe tener 8 dígitos numéricos";
        } else if (telefono != null && !telefono.isEmpty() && !telefono.matches("[0-9]{9}")) {
            mensaje = "El teléfono debe tener 9 dígitos numéricos";
        } else if (correo == null || !correo.contains("@")) {
            mensaje = "El correo debe contener @";
        } else if (dao.existeDocumento(dni, idPersona)) {
            mensaje = "Ya existe un cliente con el mismo DNI";
        } else if (dao.existeCorreo(correo, idPersona)) {
            mensaje = "Ya existe un cliente con el mismo correo";
        } else {
            PersonaDTO p = new PersonaDTO();
            p.setIdPersona(idPersona);
            p.setNombres(request.getParameter("nombres"));
            p.setApellidos(request.getParameter("apellidos"));
            p.setDocumento(dni);
            p.setTelefono(telefono);
            p.setCorreo(correo);
            p.setDireccion(request.getParameter("direccion"));
            p.setEstado(Integer.parseInt(request.getParameter("estado")));

            boolean ok = dao.editar(p);
            mensaje = ok ? "Cliente actualizado correctamente" : "Error actualizando cliente";
            toastColor = ok ? "#ffc107" : "#dc3545";
        }

    } else if ("eliminar".equals(accion)) {
        int id = Integer.parseInt(request.getParameter("idPersona"));
        boolean ok = dao.eliminar(id);
        mensaje = ok ? "Cliente eliminado correctamente" : "Error eliminando cliente";
        toastColor = "#dc3545";
    }

    List<PersonaDTO> lista = dao.listarClientes(buscar);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Gestión de Clientes - Corporación Carrasco</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
/* ====================== GENERAL ====================== */
.main-content {
    padding: 0;
    margin-left: 260px;
}

.page-header {
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding:22px 28px 12px 28px;
}

.eyebrow {
    text-transform: uppercase;
    letter-spacing:.4px;
    font-size:12px;
    color:#777;
    margin-bottom:4px;
}

.page-title {
    margin:0;
    font-size:26px;
    font-weight:700;
}

.subtitle {
    margin:0;
    color:#666;
    font-size:14px;
}

.card-panel {
    background:#fff;
    border-radius:14px;
    box-shadow:0 6px 20px rgba(0,0,0,0.08);
    margin:0 25px 20px 25px;
    padding:20px 24px;
}

/* ====================== TABLA PREMIUM ====================== */

.table-modern {
    background:white;
    border-radius:14px;
    overflow:hidden;
    box-shadow:0 4px 16px rgba(0,0,0,0.08);
}

.table-modern thead {
    background:#0d6efd;
    color:white;
    border-bottom:1px solid #dce3f0;
}

.table-modern tbody tr {
    transition:background .15s ease;
}

.table-modern tbody tr:hover {
    background:#f6f9ff;
}

.table-modern th, .table-modern td {
    padding:14px 12px !important;
    vertical-align:middle;
}

.icon-btn { width:22px; }

/* Badges */
.badge-activo {
    background:#28a745;
    padding:6px 12px;
    border-radius:10px;
}

.badge-inactivo {
    background:#dc3545;
    padding:6px 12px;
    border-radius:10px;
}

/* ====================== TOAST ====================== */
.toast-container {
    position:fixed;
    bottom:25px;
    left:25px;
    z-index:3000;
}

.toast-custom {
    padding:14px 22px;
    border-radius:25px;
    color:white;
    font-size:15px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    max-width:420px;
    white-space:nowrap;
    box-shadow:0 4px 12px rgba(0,0,0,0.25);
    transition:.4s;
}

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

.toast-close-btn:hover {
    background:rgba(255,255,255,0.4);
}

</style>
</head>

<body>

<%@ include file="../Layouts/sidebar.jsp" %>

<div class="main-content">

    <!-- ENCABEZADO -->
    <div class="page-header">
        <div>
            <div class="eyebrow">Clientes</div>
            <h2 class="page-title">Gestión de Clientes</h2>
            <p class="subtitle">Administra datos de contacto y estado</p>
        </div>

        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#modalNuevo">
            + Nuevo Cliente
        </button>
    </div>

    <!-- PANEL PRINCIPAL -->
    <div class="card-panel">

        <!-- BUSCADOR -->
        <form method="get" class="row g-2 mb-3">
            <div class="col-md-10">
                <input type="text" name="buscar" class="form-control"
                       placeholder="Buscar por nombre o DNI..."
                       value="<%= buscar %>">
            </div>
            <div class="col-md-2 d-grid">
                <button class="btn btn-primary">Buscar</button>
            </div>
        </form>

        <!-- TOAST -->
        <% if (!mensaje.equals("")) { %>
        <div class="toast-container" id="toastContainer">
            <div class="toast-custom" id="toastMsg" style="background:<%= toastColor %>;">
                <span><%= mensaje %></span>
                <button class="toast-close-btn" id="toastCloseBtn">&times;</button>
            </div>
        </div>
        <% } %>

        <!-- TABLA -->
        <div class="table-responsive">
            <table class="table table-modern">

                <thead>
                    <tr>
                        <th>#</th>
                        <th>Nombres</th>
                        <th>Apellidos</th>
                        <th>DNI</th>
                        <th>Teléfono</th>
                        <th>Correo</th>
                        <th>Dirección</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>

                <tbody>
                <%
                int i = 1;
                for (PersonaDTO p : lista) {
                %>
                    <tr>
                        <td><%= i++ %></td>
                        <td><%= p.getNombres() %></td>
                        <td><%= p.getApellidos() %></td>
                        <td><%= p.getDocumento() %></td>
                        <td><%= p.getTelefono() %></td>
                        <td><%= p.getCorreo() %></td>
                        <td><%= p.getDireccion() %></td>

                        <td>
                            <% if (p.getEstado() == 1) { %>
                                <span class="badge badge-activo">Activo</span>
                            <% } else { %>
                                <span class="badge badge-inactivo">Inactivo</span>
                            <% } %>
                        </td>

                        <td>
                            <button class="btn btn-sm btn-outline-primary btn-editar"
                                    data-id="<%= p.getIdPersona() %>"
                                    data-nombres="<%= p.getNombres() %>"
                                    data-apellidos="<%= p.getApellidos() %>"
                                    data-documento="<%= p.getDocumento() %>"
                                    data-telefono="<%= p.getTelefono() %>"
                                    data-correo="<%= p.getCorreo() %>"
                                    data-direccion="<%= p.getDireccion() %>"
                                    data-estado="<%= p.getEstado() %>">
                                <img src="${pageContext.request.contextPath}/resources/img/img_editar.png"
                                     class="icon-btn">
                            </button>

                            <form method="post" style="display:inline;">
                                <input type="hidden" name="accion" value="eliminar">
                                <input type="hidden" name="idPersona" value="<%= p.getIdPersona() %>">
                                <button type="submit" class="btn btn-sm btn-outline-danger"
                                        onclick="return confirm('¿Eliminar este cliente?');">
                                    <img src="${pageContext.request.contextPath}/resources/img/img_eliminar.png"
                                         class="icon-btn">
                                </button>
                            </form>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>

    </div>
</div>

<!-- ============================= -->
<!-- MODAL NUEVO CLIENTE -->
<!-- ============================= -->
<div class="modal fade" id="modalNuevo">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <form method="post">
                <input type="hidden" name="accion" value="guardar">

                <div class="modal-header">
                    <h5 class="modal-title">Registrar Cliente</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label>Nombres</label>
                        <input type="text" name="nombres" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label>Apellidos</label>
                        <input type="text" name="apellidos" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label>DNI</label>
                        <input type="text" name="documento" class="form-control" maxlength="8"
                               pattern="\d{8}" required>
                    </div>
                    <div class="col-md-4">
                        <label>Teléfono</label>
                        <input type="text" name="telefono" class="form-control" maxlength="9"
                               pattern="\d{9}">
                    </div>
                    <div class="col-md-4">
                        <label>Correo</label>
                        <input type="email" name="correo" class="form-control" required>
                    </div>
                    <div class="col-md-8">
                        <label>Dirección</label>
                        <input type="text" name="direccion" class="form-control">
                    </div>
                    <div class="col-md-4">
                        <label>Estado</label>
                        <select name="estado" class="form-select">
                            <option value="1">Activo</option>
                            <option value="0">Inactivo</option>
                        </select>
                    </div>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button class="btn btn-success">Guardar</button>
                </div>

            </form>

        </div>
    </div>
</div>

<!-- ============================= -->
<!-- MODAL EDITAR CLIENTE -->
<!-- ============================= -->
<div class="modal fade" id="modalEditar">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <form method="post">
                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="idPersona" id="edit-id">

                <div class="modal-header">
                    <h5 class="modal-title">Editar Cliente</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body row g-3">
                    <div class="col-md-6">
                        <label>Nombres</label>
                        <input type="text" id="edit-nombres" name="nombres" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label>Apellidos</label>
                        <input type="text" id="edit-apellidos" name="apellidos" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label>DNI</label>
                        <input type="text" id="edit-documento" name="documento" maxlength="8"
                               pattern="\d{8}" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label>Teléfono</label>
                        <input type="text" id="edit-telefono" name="telefono" maxlength="9"
                               pattern="\d{9}" class="form-control">
                    </div>
                    <div class="col-md-4">
                        <label>Correo</label>
                        <input type="email" id="edit-correo" name="correo" class="form-control" required>
                    </div>
                    <div class="col-md-8">
                        <label>Dirección</label>
                        <input type="text" id="edit-direccion" name="direccion" class="form-control">
                    </div>
                    <div class="col-md-4">
                        <label>Estado</label>
                        <select id="edit-estado" name="estado" class="form-select">
                            <option value="1">Activo</option>
                            <option value="0">Inactivo</option>
                        </select>
                    </div>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button class="btn btn-primary">Guardar cambios</button>
                </div>

            </form>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
/* Modal Editar */
document.querySelectorAll('.btn-editar').forEach(btn => {
    btn.addEventListener('click', function () {
        document.getElementById('edit-id').value        = this.dataset.id;
        document.getElementById('edit-nombres').value   = this.dataset.nombres;
        document.getElementById('edit-apellidos').value = this.dataset.apellidos;
        document.getElementById('edit-documento').value = this.dataset.documento;
        document.getElementById('edit-telefono').value  = this.dataset.telefono;
        document.getElementById('edit-correo').value    = this.dataset.correo;
        document.getElementById('edit-direccion').value = this.dataset.direccion;
        document.getElementById('edit-estado').value    = this.dataset.estado;

        new bootstrap.Modal(document.getElementById('modalEditar')).show();
    });
});

/* Toast */
function cerrarToast() {
    const toast = document.getElementById("toastMsg");
    const cont  = document.getElementById("toastContainer");
    if (!toast) return;
    toast.style.opacity = "0";
    setTimeout(() => { if (cont) cont.remove(); }, 400);
}

document.addEventListener("DOMContentLoaded", () => {
    const btn = document.getElementById("toastCloseBtn");
    if (btn) btn.addEventListener("click", cerrarToast);
});

setTimeout(cerrarToast, 4000);
</script>

</body>
</html>
