package DAO;

import DTO.DetalleTransaccionDTO;
import DTO.TransaccionDTO;
import UTIL.Conexion;
import java.sql.*;
import java.util.List;

public class TransaccionDAO {
// AUN NO FUNCIONAL :V
    // tipoOperacion: 1=COMPRA, 2=VENTA (debes tener estos registros en Operaciones)
    public boolean registrarTransaccion(TransaccionDTO cabecera,
                                        List<DetalleTransaccionDTO> detalles,
                                        boolean esVenta) {
        String sqlTrans = "INSERT INTO Transacciones(idOperacion,idPersona,idUsuario,metodoPago,total) " +
                          "VALUES(?,?,?,?,?)";
        String sqlDet = "INSERT INTO DetalleTransacciones(idTransaccion,idProducto,cantidad,precioUnitario) " +
                        "VALUES(?,?,?,?)";

        Connection cn = null;
        try {
            cn = Conexion.conectar();
            cn.setAutoCommit(false);

            // 1. Insert cabecera
            int idGenerado;
            try (PreparedStatement ps = cn.prepareStatement(sqlTrans, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, cabecera.getIdOperacion());
                ps.setInt(2, cabecera.getIdPersona());
                ps.setInt(3, cabecera.getIdUsuario());
                ps.setString(4, cabecera.getMetodoPago());
                ps.setDouble(5, cabecera.getTotal());
                ps.executeUpdate();

                ResultSet rs = ps.getGeneratedKeys();
                rs.next();
                idGenerado = rs.getInt(1);
            }

            // 2. Insert detalles + actualizar stock
            ProductoDAO productoDAO = new ProductoDAO();

            try (PreparedStatement psDet = cn.prepareStatement(sqlDet)) {
                for (DetalleTransaccionDTO d : detalles) {
                    psDet.setInt(1, idGenerado);
                    psDet.setInt(2, d.getIdProducto());
                    psDet.setInt(3, d.getCantidad());
                    psDet.setDouble(4, d.getPrecioUnitario());
                    psDet.addBatch();

                    //productoDAO.actualizarStock(d.getIdProducto(), d.getCantidad(), esVenta);
                }
                psDet.executeBatch();
            }

            cn.commit();
            return true;

        } catch (Exception e) {
            System.out.println("Error registrar transacción: " + e.getMessage());
            if (cn != null) try { cn.rollback(); } catch (Exception ignore) {}
            return false;
        } finally {
            if (cn != null) try { cn.setAutoCommit(true); cn.close(); } catch (Exception ignore) {}
        }
    }
}
