<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="DAO.PersonaDAO,DTO.PersonaDTO,java.util.*" %>

<%
request.setAttribute("rolesPermitidos", "Administrador");
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

    /* CRUD */
    if ("guardar".equals(accion)) {

        String ruc = request.getParameter("ruc");
        String telefono = request.getParameter("telefono");
        String correo = request.getParameter("correo");

        if (ruc == null || !ruc.matches("[0-9]{11}")) {
            mensaje = "El RUC debe tener 11 dígitos";
        } else if (telefono != null && !telefono.isEmpty() && !telefono.matches("[0-9]{9}")) {
            mensaje = "El teléfono debe tener 9 dígitos";
        } else if (correo == null || !correo.contains("@")) {
            mensaje = "El correo debe contener @";
        } else if (dao.existeRuc(ruc, null)) {
            mensaje = "Ya existe un proveedor con el mismo RUC";
        } else if (dao.existeCorreo(correo, null)) {
            mensaje = "Ya existe un proveedor con el mismo correo";
        } else {

            PersonaDTO p = new PersonaDTO();
            p.setIdTipoPersona(3);
            p.setRazonSocial(request.getParameter("razonSocial"));
            p.setRuc(ruc);
            p.setTelefono(telefono);
            p.setCorreo(correo);
            p.setDireccion(request.getParameter("direccion"));
            p.setEstado(Integer.parseInt(request.getParameter("estado")));

            boolean ok = dao.registrarProveedor(p);
            mensaje = ok ? "Proveedor registrado correctamente" : "Error registrando proveedor";
            toastColor = ok ? "#0dcaf0" : "#dc3545";
        }

    } else if ("editar".equals(accion)) {

        int id = Integer.parseInt(request.getParameter("idPersona"));
        String ruc = request.getParameter("ruc");
        String telefono = request.getParameter("telefono");
        String correo = request.getParameter("correo");

        if (ruc == null || !ruc.matches("[0-9]{11}")) {
            mensaje = "El RUC debe tener 11 dígitos";
        } else if (telefono != null && !telefono.isEmpty() && !telefono.matches("[0-9]{9}")) {
            mensaje = "El teléfono debe tener 9 dígitos";
        } else if (correo == null || !correo.contains("@")) {
            mensaje = "El correo debe contener @";
        } else if (dao.existeRuc(ruc, id)) {
            mensaje = "Ya existe un proveedor con el mismo RUC";
        } else if (dao.existeCorreo(correo, id)) {
            mensaje = "Ya existe un proveedor con el mismo correo";
        } else {

            PersonaDTO p = new PersonaDTO();
            p.setIdPersona(id);
            p.setRazonSocial(request.getParameter("razonSocial"));
            p.setRuc(ruc);
            p.setTelefono(telefono);
            p.setCorreo(correo);
            p.setDireccion(request.getParameter("direccion"));
            p.setEstado(Integer.parseInt(request.getParameter("estado")));

            boolean ok = dao.editarProveedor(p);
            mensaje = ok ? "Proveedor actualizado correctamente" : "Error actualizando proveedor";
            toastColor = ok ? "#ffc107" : "#dc3545";
        }

    } else if ("eliminar".equals(accion)) {

        int id = Integer.parseInt(request.getParameter("idPersona"));
        boolean ok = dao.eliminar(id);
        mensaje = ok ? "Proveedor eliminado correctamente" : "Error eliminando proveedor";
        toastColor = "#dc3545";
    }

    List<PersonaDTO> lista = dao.listarProveedores(buscar);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Gestión de Proveedores – Corporación Carrasco</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
.main-content { margin-left: 260px; padding: 25px; }

/* ================== TABLA PREMIUM ================== */

.table-premium {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 12px;
}

.table-premium thead tr {
    background: rgba(13,110,253,0.15);
    backdrop-filter: blur(8px);
}

.table-premium thead th {
    padding: 15px;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 13px;
    color: #003f9e;
    border-bottom: 2px solid #d8e2ff;
}

.table-premium tbody tr {
    background: #fff;
    box-shadow: 0 4px 18px rgba(0,0,0,0.06);
    border-radius: 12px;
    transition: .15s ease;
}

.table-premium tbody tr:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 25px rgba(0,0,0,0.12);
}

.table-premium tbody td {
    padding: 16px 20px;
    vertical-align: middle;
    border-top: none;
}

.table-premium tbody tr td:first-child { border-radius: 12px 0 0 12px; }
.table-premium tbody tr td:last-child  { border-radius: 0 12px 12px 0; }

/* ICONOS ACCIONES */
.btn-action-premium {
    width: 38px;
    height: 38px;
    border-radius: 10px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: .2s;
}
.btn-action-premium:hover {
    transform: scale(1.12);
    box-shadow: 0 3px 8px rgba(0,0,0,0.18);
}
.btn-edit { background:#e6f0ff; border:1px solid #bcd2ff; }
.btn-edit img { width: 17px; }

.btn-delete { background:#ffe6e9; border:1px solid #ffc4ca; }
.btn-delete img { width: 17px; }

/* MONOESPACIADO RUC */
.ruc-mono { font-family: "Consolas", monospace; letter-spacing: 1px; }

/* BADGES PREMIUM */
.badge-activo {
    background:#00c853;
    padding:6px 12px;
    font-size:13px;
    border-radius:25px;
}
.badge-inactivo {
    background:#e53935;
    padding:6px 12px;
    font-size:13px;
    border-radius:25px;
}

/* TOAST */
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
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    pointer-events: auto;
}

.toast-close-btn:hover {
    background: rgba(255,255,255,0.40);

</style>
</head>

<body>

<%@ include file="../Layouts/sidebar.jsp" %>

<div class="main-content">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <div style="text-transform: uppercase; color:#777; font-size:12px;">Proveedores</div>
            <h3 class="fw-bold">Gestión de Proveedores</h3>
        </div>

        <button class="btn btn-success px-4" data-bs-toggle="modal" data-bs-target="#modalNuevo">
            + Nuevo Proveedor
        </button>
    </div>

    <!-- BUSCADOR -->
    <form method="get" class="row g-2 mb-4">
        <div class="col-md-10">
            <input type="text" name="buscar" class="form-control form-control-lg"
                   placeholder="Buscar por Razón Social o RUC..." value="<%= buscar %>">
        </div>
        <div class="col-md-2 d-grid">
            <button class="btn btn-primary btn-lg">Buscar</button>
        </div>
    </form>

    <% if (!mensaje.equals("")) { %>
        <div class="toast-container">
            <div class="toast-custom" style="background:<%=toastColor%>;">
                <span><%=mensaje%></span>
                <button class="toast-close-btn" onclick="this.parentElement.style.opacity='0'">&times;</button>
            </div>
        </div>
    <% } %>

    <!-- TABLA PREMIUM -->
    <div class="table-responsive">
        <table class="table-premium align-middle">

            <thead>
                <tr>
                    <th>#</th>
                    <th>Razón Social</th>
                    <th>RUC</th>
                    <th>Teléfono</th>
                    <th>Correo</th>
                    <th>Dirección</th>
                    <th>Estado</th>
                    <th style="width:150px;">Acciones</th>
                </tr>
            </thead>

            <tbody>
                <%
                int i = 1;
                for (PersonaDTO p : lista) {
                %>
                <tr>
                    <td><%= i++ %></td>

                    <td class="fw-semibold"><%= p.getRazonSocial() %></td>

                    <td class="ruc-mono"><%= p.getRuc() %></td>

                    <td>
                        📞 <%= p.getTelefono() %>
                    </td>

                    <td>
                        ✉️ <%= p.getCorreo() %>
                    </td>

                    <td><%= p.getDireccion() %></td>

                    <td>
                        <% if (p.getEstado() == 1) { %>
                            <span class="badge-activo">Activo</span>
                        <% } else { %>
                            <span class="badge-inactivo">Inactivo</span>
                        <% } %>
                    </td>

                    <td class="d-flex gap-2">

                        <!-- EDITAR -->
                        <button type="button" class="btn-action-premium btn-edit btn-editar"
                                data-id="<%= p.getIdPersona() %>"
                                data-razon="<%= p.getRazonSocial() %>"
                                data-ruc="<%= p.getRuc() %>"
                                data-telefono="<%= p.getTelefono() %>"
                                data-correo="<%= p.getCorreo() %>"
                                data-direccion="<%= p.getDireccion() %>"
                                data-estado="<%= p.getEstado() %>">
                            <img src="${pageContext.request.contextPath}/resources/img/img_editar.png">
                        </button>

                        <!-- ELIMINAR -->
                        <form method="post">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="idPersona" value="<%= p.getIdPersona() %>">

                            <button class="btn-action-premium btn-delete"
                                    onclick="return confirm('¿Eliminar este proveedor?');">
                                <img src="${pageContext.request.contextPath}/resources/img/img_eliminar.png">
                            </button>
                        </form>
                    </td>

                </tr>
                <% } %>
            </tbody>
        </table>
    </div>

</div>

<!-- MODALES (SIN CAMBIAR LÓGICA) -->
<!-- ============================== -->
<!--    MODAL NUEVO PROVEEDOR      -->
<!-- ============================== -->

<div class="modal fade" id="modalNuevo" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <form method="post">
                <input type="hidden" name="accion" value="guardar">

                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Registrar Proveedor</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body row g-3">

                    <div class="col-md-8">
                        <label class="form-label">Razón Social</label>
                        <input type="text" name="razonSocial" class="form-control" required>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">RUC</label>
                        <input type="text" name="ruc" class="form-control" required maxlength="11">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Teléfono</label>
                        <input type="text" name="telefono" class="form-control" maxlength="9">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Correo</label>
                        <input type="email" name="correo" class="form-control" required>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Estado</label>
                        <select name="estado" class="form-select">
                            <option value="1">Activo</option>
                            <option value="0">Inactivo</option>
                        </select>
                    </div>

                    <div class="col-md-12">
                        <label class="form-label">Dirección</label>
                        <input type="text" name="direccion" class="form-control">
                    </div>

                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button class="btn btn-success px-4">Guardar</button>
                </div>

            </form>

        </div>
    </div>
</div>

<!-- ============================== -->
<!--      MODAL EDITAR PROVEEDOR   -->
<!-- ============================== -->

<div class="modal fade" id="modalEditar" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <form method="post">
                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="idPersona" id="edit-id">

                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Editar Proveedor</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body row g-3">

                    <div class="col-md-8">
                        <label class="form-label">Razón Social</label>
                        <input type="text" name="razonSocial" id="edit-razon" class="form-control" required>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">RUC</label>
                        <input type="text" name="ruc" id="edit-ruc" class="form-control" required maxlength="11">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Teléfono</label>
                        <input type="text" name="telefono" id="edit-telefono" class="form-control" maxlength="9">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Correo</label>
                        <input type="email" name="correo" id="edit-correo" class="form-control" required>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label">Estado</label>
                        <select name="estado" id="edit-estado" class="form-select">
                            <option value="1">Activo</option>
                            <option value="0">Inactivo</option>
                        </select>
                    </div>

                    <div class="col-md-12">
                        <label class="form-label">Dirección</label>
                        <input type="text" name="direccion" id="edit-direccion" class="form-control">
                    </div>

                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button class="btn btn-primary px-4">Guardar Cambios</button>
                </div>

            </form>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
// Rellenar modal editar
document.querySelectorAll(".btn-editar").forEach(btn => {
    btn.addEventListener("click", () => {
        document.getElementById("edit-id").value = btn.dataset.id;
        document.getElementById("edit-razon").value = btn.dataset.razon;
        document.getElementById("edit-ruc").value = btn.dataset.ruc;
        document.getElementById("edit-telefono").value = btn.dataset.telefono;
        document.getElementById("edit-correo").value = btn.dataset.correo;
        document.getElementById("edit-direccion").value = btn.dataset.direccion;
        document.getElementById("edit-estado").value = btn.dataset.estado;

        new bootstrap.Modal(document.getElementById("modalEditar")).show();
    });
});
</script>

</body>
</html>
