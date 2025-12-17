package DAO;

import DTO.RolDTO;
import UTIL.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RolDAO {

    Connection con;
    PreparedStatement ps;
    ResultSet rs;

    public RolDAO() {
        con = Conexion.conectar();
    }

    public List<RolDTO> listar() {
        List<RolDTO> lista = new ArrayList<>();
        String sql = "SELECT * FROM roles";

        try {
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                RolDTO r = new RolDTO();
                r.setIdRol(rs.getInt("idRol"));
                r.setNombreRol(rs.getString("nombreRol"));
                lista.add(r);
            }

        } catch (Exception e) {
            System.out.println("Error listar roles: " + e.getMessage());
        }

        return lista;
    }
}
