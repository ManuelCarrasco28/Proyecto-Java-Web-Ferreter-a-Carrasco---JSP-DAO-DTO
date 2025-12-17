package DAO;

import DTO.ReporteVentaDTO;
import UTIL.Conexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReporteDAO {

    public List<ReporteVentaDTO> listarVentas(String fechaInicio, String fechaFin) {

        List<ReporteVentaDTO> lista = new ArrayList<>();

        String sql =
            "SELECT t.idTransaccion, t.fecha, t.total, t.metodoPago, " +
            "       c.nombres AS clienteNombres, c.apellidos AS clienteApellidos, " +
            "       u.nombres AS usuarioNombres, u.apellidos AS usuarioApellidos " +
            "FROM transacciones t " +
            "INNER JOIN persona c ON c.idPersona = t.idPersona " +
            "INNER JOIN usuario u ON u.idUsuario = t.idUsuario " +
            "WHERE t.idOperacion = 2 "; // 2 = VENTA

        // Si tiene filtros
        if (fechaInicio != null && !fechaInicio.isEmpty()) {
            sql += " AND t.fecha >= ? ";
        }
        if (fechaFin != null && !fechaFin.isEmpty()) {
            sql += " AND t.fecha <= ? ";
        }

        sql += " ORDER BY t.fecha DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            int index = 1;

            if (fechaInicio != null && !fechaInicio.isEmpty()) {
                ps.setString(index++, fechaInicio);
            }
            if (fechaFin != null && !fechaFin.isEmpty()) {
                ps.setString(index++, fechaFin);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ReporteVentaDTO r = new ReporteVentaDTO();
                r.setIdTransaccion(rs.getInt("idTransaccion"));
                r.setFecha(rs.getString("fecha"));
                r.setTotal(rs.getDouble("total"));
                r.setMetodoPago(rs.getString("metodoPago"));
                r.setCliente(rs.getString("clienteNombres") + " " + rs.getString("clienteApellidos"));
                r.setUsuario(rs.getString("usuarioNombres") + " " + rs.getString("usuarioApellidos"));

                lista.add(r);
            }

        } catch (Exception e) {
            System.out.println("Error listarVentas: " + e.getMessage());
        }

        return lista;
    }
}
