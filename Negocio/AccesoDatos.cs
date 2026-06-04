using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Specialized;


namespace Negocio
{
    public class AccesoDatos
    {
        private SqlConnection conexion;
        private SqlCommand conexionCommand;
        public SqlDataReader Lector { get; set; }

        public AccesoDatos()
        {
            string cadena = ConfigurationManager.ConnectionStrings["ComplejoDep"].ConnectionString;
            conexion = new SqlConnection(cadena);
            conexionCommand = new SqlCommand();
            conexionCommand.Connection = conexion;
        }

        public void SetearConsulta(string consulta)
        {
            conexionCommand.CommandType = CommandType.Text;
            conexionCommand.CommandText = consulta;
        }

        public void SetearProcedimiento(string nombre)
        {
            conexionCommand.CommandType = CommandType.StoredProcedure;
            conexionCommand.CommandText = nombre;
        }

        public void AgregarParametro(string nombre, object valor)
        {
            conexionCommand.Parameters.AddWithValue(nombre, valor);
        }

        public void EjecutarLectura()
        {
            conexion.Open();
            Lector = conexionCommand.ExecuteReader();
        }

        public void EjecutarAccion()
        {
            conexion.Open();
            conexionCommand.ExecuteNonQuery();
            conexion.Close();
        }

        public int EjecutarAccionScalar()
        {
            conexion.Open();
            int resultado = (int)conexionCommand.ExecuteScalar();
            conexion.Close();
            return resultado;
        }

        public void CerrarConexion()
        {
            Lector?.Close();
            conexion.Close();
        }
    }
}

