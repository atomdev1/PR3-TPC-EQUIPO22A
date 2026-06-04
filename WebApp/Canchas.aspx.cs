using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Dominio;
using Negocio;

namespace WebApp
{
    public partial class Canchas : System.Web.UI.Page
    {
        protected Repeater rptCanchas;
        protected Label lblTotal;
        protected TextBox txtNombre;
        protected TextBox txtNumero;
        protected DropDownList ddlDeporte;
        protected TextBox txtCapacidad;
        protected TextBox txtPrecio;
        protected TextBox txtSena;
        protected TextBox txtDescripcion;
        protected Button btnGuardarCancha;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarCanchas();
                CargarDeportes();
            }
        }

        private void CargarCanchas()
        {
            NegocioCanchas nCanchas = new NegocioCanchas();
            List<Cancha> canchas = negocio.ObtenerTodas();

            rptCanchas.DataSource = canchas;
            rptCanchas.DataBind();

            lblTotal.Text = canchas.Count + " canchas registradas";
        }

        protected void rptCanchas_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idCancha = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Response.Redirect("EditarCancha.aspx?id=" + idCancha);
            }
            else if (e.CommandName == "Eliminar")
            {
                new NegocioCanchas().BajaLogica(idCancha);
                CargarCanchas();
            }
        }

        private void CargarDeportes()
        {
            NegocioCanchas nCanchas = new NegocioCanchas();

            ddlDeporte.DataSource = nCanchas.ObtenerCanchas();
            ddlDeporte.DataTextField = "Nombre";
            ddlDeporte.DataValueField = "IdDeporte";
            ddlDeporte.DataBind();
            ddlDeporte.Items.Insert(0, new ListItem("-- Seleccioná un deporte --", "0"));
        }

        protected string GetDeporteEmoji(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "⚽";
            if (nombre.Contains("tenis")) return "🎾";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "🏀";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "🏓";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "🏐";
            return "🏟️";
        }

        protected string FormatearPrecio(object precioObj)
        {
            return "$" + precioObj + " /hora";
        }

        protected string GetDeporteAccent(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "#2d6a4f";
            if (nombre.Contains("tenis")) return "#b5870a";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "#9b4d96";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "#1a6fa8";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "#c0392b";
            return "#4a5568";
        }

        protected void btnGuardarCancha_Click(object sender, EventArgs e)
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

            new NegocioCanchas().Agregar(cancha);
            Response.Redirect("Canchas.aspx");
        }
    }
}
