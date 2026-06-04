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
            try
            {
                conexion.Open();
                Lector = conexionCommand.ExecuteReader();
            }
            catch (Exception)
            {
                // si falla cierro aca asi no queda abierta, sino la cierra el que hace el mapeo
                CerrarConexion();
                throw;
            }
        }

        public void EjecutarAccion()
        {
            try
            {
                conexion.Open();
                conexionCommand.ExecuteNonQuery();
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                conexion.Close();
            }
        }

        public int EjecutarAccionScalar()
        {
            try
            {
                conexion.Open();
                return (int)conexionCommand.ExecuteScalar();
            }
            catch (Exception)
            {
                throw;
            }
            finally
            {
                conexion.Close();
            }
        }

        public void CerrarConexion()
        {
            Lector?.Close();
            conexion.Close();
        }
    }
}

