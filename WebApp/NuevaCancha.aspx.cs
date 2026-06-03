using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Dominio;

namespace WebApp
{
    public partial class NuevaCancha : System.Web.UI.Page
    {
        protected TextBox txtNombre;
        protected TextBox txtNumero;
        protected DropDownList ddlDeporte;
        protected TextBox txtCapacidad;
        protected TextBox txtPrecio;
        protected TextBox txtSena;
        protected TextBox txtDescripcion;
        protected Button btnGuardar;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarDeportes();
            }
        }

        private void CargarDeportes()
        {
            List<Deporte> deportes = new List<Deporte>
            {
                new Deporte { IdDeporte = 1, Nombre = "Tenis", DuracionMinutos = 60 },
                new Deporte { IdDeporte = 2, Nombre = "Pádel", DuracionMinutos = 60 },
                new Deporte { IdDeporte = 3, Nombre = "Fútbol", DuracionMinutos = 90 },
                new Deporte { IdDeporte = 4, Nombre = "Voley", DuracionMinutos = 60 },
                new Deporte { IdDeporte = 5, Nombre = "Básquet", DuracionMinutos = 40 },
            };

            ddlDeporte.DataSource = deportes;
            ddlDeporte.DataTextField = "Nombre";
            ddlDeporte.DataValueField = "IdDeporte";
            ddlDeporte.DataBind();

            ddlDeporte.Items.Insert(0, new ListItem("-- Seleccioná un deporte --", "0"));
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            Cancha cancha = new Cancha
            {
                NombreFantasia = txtNombre.Text.Trim(),
                Numero = int.Parse(txtNumero.Text),
                IdDeporte = int.Parse(ddlDeporte.SelectedValue),
                CapacidadJugadores = int.Parse(txtCapacidad.Text),
                Precio = decimal.Parse(txtPrecio.Text),
                MontoSena = decimal.Parse(txtSena.Text),
                Descripcion = txtDescripcion.Text.Trim(),
                Activa = true
            };

            // TODO: llamar a la capa Negocio para guardar la cancha
            Response.Redirect("Canchas.aspx");
        }
    }
}
