<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ControlManual.aspx.cs" Inherits="PDC.ControlManual" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <script type="text/javascript">
         function ChangeCheckBoxState(id, checkState) {
             var cb = document.getElementById(id);
             if (cb != null)
                 cb.checked = checkState;
         }

         function ChangeAllCheckBoxAvailStates(checkState) {
             // Toggles through all of the checkboxes defined in the CheckBoxIDs array
             // and updates their value to the checkState input parameter
             //var arr = eval('CheckBox'+WhichJobs+'IDs');
             if (CheckBoxAvailIDs != null) {
                 for (var i = 0; i < CheckBoxAvailIDs.length; i++)
                     ChangeCheckBoxState(CheckBoxAvailIDs[i], checkState);
             }
         }

         function ChangeAllCheckBoxSelectedStates(checkState) {
             // Toggles through all of the checkboxes defined in the CheckBoxIDs array
             // and updates their value to the checkState input parameter
             //var arr = eval('CheckBox'+WhichJobs+'IDs');
             if (CheckBoxSelectedIDs != null) {
                 for (var i = 0; i < CheckBoxSelectedIDs.length; i++)
                     ChangeCheckBoxState(CheckBoxSelectedIDs[i], checkState);
             }
         }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <asp:Panel ID="p_Manual_Init" runat="server" EnableViewState="True" CssClass="PortletBoxInner" Visible="False">
     <p>
        <span class="ModuleHeader">Step 1: Select Date and Description</span>
     </p>          
        Select date: 
        
        <asp:Calendar ID="Calendar1" runat="server" 
         onselectionchanged="Calendar1_SelectionChanged" EnableViewState="False" SelectedDayStyle-BackColor="#466B8B"></asp:Calendar>
        <br /><!-- <asp:TextBox ID="tManBatchDate" runat="server" ReadOnly="false"></asp:TextBox> -->
        <br />

        Manual batch description: 
        <asp:TextBox ID="tManBatchDesc" runat="server"></asp:TextBox>
        <div class="breaker_portlet">
            &nbsp;</div>
        <asp:LinkButton ID="LBManBatchInit" runat="server"  CommandName="COMMAND_MANBATCH_INIT" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>Init</span></asp:LinkButton>
        
        <div class="breaker_portlet">
            &nbsp;</div>

    </asp:Panel>
    <asp:Panel ID="p_Manual_Init_Done" runat="server" EnableViewState="True" CssClass="PortletBoxInner"
        Visible="False">
        <p>
        <span class="ModuleHeader">Step 1: Selected Date and Description</span>
        </p>
        Selected date:&nbsp;
        <asp:Label ID="lManBatchSelectedDate" runat="server" Text="N/A"></asp:Label>
        <br />
        Manual batch description:&nbsp;
        <asp:Label ID="lManBatchSelectedDesc" runat="server" Text="N/A"></asp:Label>
        
        <div class="breaker_portlet">
            &nbsp;</div>
    </asp:Panel>
    <asp:Panel ID="p_Detail_lvl1" runat="server" EnableViewState="False" CssClass="PortletBoxInner" Visible="False">
     <p>
        <span class="ModuleHeader">Step 2: Select jobs for Manual Batch</span>
     </p>       
        <table width="100%" class="scrollable">
            <tr>
                <td width="48%">
                    <p>
                        <span class="ModuleHeader">Available Jobs&nbsp;(<asp:Label ID="lDetailRowCountAvail" runat="server" Text="-" EnableViewState="False"></asp:Label>
                        )</span>
                    </p>
                </td>
                <td width="4%">
      &nbsp;
                </td>
                <td width="48%">
                    <p>
                        <span class="ModuleHeader">Selected Jobs&nbsp;(<asp:Label ID="lDetailRowCountSelected" runat="server" Text="-" EnableViewState="False"></asp:Label>
                        )</span>
                    </p>
                </td>
            </tr>
            <tr>
                <td>
                    <p class="PDCPagingInfo">
                        <asp:Label ID="PagingInformationAvail" runat="server" Text=""></asp:Label>
            &nbsp; Number of rows per page: &nbsp;
                        <asp:DropDownList ID="PagerCountperPage" runat="server" AutoPostBack="True" OnSelectedIndexChanged="PagerCountperPage_SelectedIndexChanged">
								<asp:ListItem Enabled="false" Value="Dummy due to asp bug"/>
								<asp:ListItem Value="10"></asp:ListItem>
								<asp:ListItem>20</asp:ListItem>
								<asp:ListItem>30</asp:ListItem>
								<asp:ListItem>40</asp:ListItem>
								<asp:ListItem>50</asp:ListItem>
								<asp:ListItem>100</asp:ListItem>
								<asp:ListItem>200</asp:ListItem>
								<asp:ListItem>300</asp:ListItem>
								<asp:ListItem>400</asp:ListItem>
								<asp:ListItem>500</asp:ListItem>
                        </asp:DropDownList>
                    </p>
                    <asp:Literal ID="CheckBoxAvailIDsArray" runat="server" EnableViewState="False"></asp:Literal>
                </td>
                <td>
                </td>
                <td>
      &nbsp;
                    <p class="PDCPagingInfo">
                        <asp:Label ID="PagingInformationSelected" runat="server" Text=""></asp:Label>
                    </p>
                    <asp:Literal ID="CheckBoxSelectedIDsArray" runat="server" EnableViewState="False"></asp:Literal>
                </td>
            </tr>
            <tr>
              <td colspan="3" align="center">
                    <asp:DropDownList ID="DDL_RequestAcc" runat="server" EnableViewState="False">
                        <asp:ListItem Enabled="false" Value="Dummy due to asp bug"/>
                        <asp:ListItem Value="1">Selected Job only</asp:ListItem>
                        <asp:ListItem Value="2">Selected and Children</asp:ListItem>
                        <asp:ListItem Value="3">Selected and Parents</asp:ListItem>
                        <asp:ListItem Value="4">Selected and Parents and Children</asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>
            <tr valign="top">
                <td>
                    <div class="scrollable">
                        <asp:GridView 
                ID="gv_ManBatch_Available_Jobs" 
                runat="server" 
                DataKeyNames="JOB_ID" 
                DataSourceID="SqlDataSource_gv_ManBatch_Available_Jobs"

                AllowSorting="True" 
                AutoGenerateColumns="False" 
                CellPadding="2" 
                CellSpacing="1"
                GridLines="None" 
                CssClass="PDCTbl" 
                EmptyDataText="No rows" 
                EnableViewState="False" 
                AllowPaging="True" 
                ondatabound="gv_ManBatch_Available_Jobs_DataBound"
                PagerSettings-Position="TopAndBottom" 
                PagerSettings-Mode="NumericFirstLast" 
                ViewStateMode="Disabled"  >
                            <Columns>
                                <asp:TemplateField ControlStyle-CssClass="gridCheckBox">
                                    <HeaderTemplate>
                                        <asp:CheckBox runat="server" ID="HeaderLevelCheckBox" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox runat="server" ID="RowLevelCheckBox" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="JOB_ID" HeaderText="JOB_ID" ReadOnly="True" SortExpression="JOB_ID" />
                                <asp:BoundField DataField="JOB_NAME" HeaderText="JOB_NAME" ReadOnly="True" SortExpression="JOB_NAME" />
                            </Columns>
                            <RowStyle CssClass="PDCTblRow" Wrap="False" />
                            <SelectedRowStyle CssClass="PDCTblSelRow" />
                            <SortedAscendingHeaderStyle CssClass="sort_asc" />
                            <SortedDescendingHeaderStyle CssClass="sort_desc" />
                            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
                            <HeaderStyle CssClass="PDCTblHeader" />
                            <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom" />
                            <PagerStyle CssClass="PDCTblPaging" />
                        </asp:GridView>
                    </div>
                    <asp:SqlDataSource 
            ID="SqlDataSource_gv_ManBatch_Available_Jobs" 
            runat="server" 
            onselected="SqlDataSourceAvailJobs_Selected" 
            onselecting="SqlDataSource_Selecting"
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" 
            EnableViewState="False" 
            SelectCommand="PCKG_GUI.SP_GUI_MBATCH_AVAIL_JBS" 
            SelectCommandType="StoredProcedure" >
                        <SelectParameters>
                            <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
                            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
                            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_STREAM_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_JOB_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_JOB_TYPE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_TABLE_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_PHASE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_JOB_CATEGORY_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                            <asp:SessionParameter Name="VALUES_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                        </SelectParameters>
                    </asp:SqlDataSource>
                    <div class="breaker_portlet">
                        &nbsp;</div>
                </td>
                <td align="center" valign="middle">
                    
                    <asp:LinkButton ID="LBManBatchSet" runat="server"  CommandName="COMMAND_MANBATCH_SET" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>&gt;</span></asp:LinkButton>
                    <div class="breaker_portlet">
                        &nbsp;</div>
                    <asp:LinkButton ID="LBManBatchUnset" runat="server"  CommandName="COMMAND_MANBATCH_UNSET" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span>&lt;</span></asp:LinkButton>
                </td>
                <td>
                    <div class="scrollable">
                        <asp:GridView 
                ID="gv_ManBatch_Selected_Jobs" 
                runat="server" 
                DataKeyNames="JOB_ID" 
                DataSourceID="SqlDataSource_gv_ManBatch_Selected_Jobs"
                AllowSorting="True" 
                AutoGenerateColumns="False" 
                CellPadding="2" 
                CellSpacing="1"
                GridLines="None" 
                CssClass="PDCTbl" 
                EmptyDataText="No rows" 
                EnableViewState="False" 
                AllowPaging="True" 
                ondatabound="gv_ManBatch_Selected_Jobs_DataBound" 
                PagerSettings-Position="TopAndBottom" 
                PagerSettings-Mode="NumericFirstLast" 
                ViewStateMode="Disabled">
                            <Columns>
                                <asp:TemplateField ControlStyle-CssClass="gridCheckBox">
                                    <HeaderTemplate>
                                        <asp:CheckBox runat="server" ID="HeaderLevelCheckBox" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox runat="server" ID="RowLevelCheckBox" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="JOB_ID" HeaderText="JOB_ID" ReadOnly="True" SortExpression="JOB_ID" />
                                <asp:BoundField DataField="JOB_NAME" HeaderText="JOB_NAME" ReadOnly="True" SortExpression="JOB_NAME" />
                            </Columns>
                            <RowStyle CssClass="PDCTblRow" Wrap="False" />
                            <SelectedRowStyle CssClass="PDCTblSelRow" />
                            <SortedAscendingHeaderStyle CssClass="sort_asc" />
                            <SortedDescendingHeaderStyle CssClass="sort_desc" />
                            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
                            <HeaderStyle CssClass="PDCTblHeader" />
                            <PagerSettings Mode="NumericFirstLast" Position="TopAndBottom" />
                            <PagerStyle CssClass="PDCTblPaging" />
                        </asp:GridView>
                    </div>
                    <asp:SqlDataSource 
            ID="SqlDataSource_gv_ManBatch_Selected_Jobs" 
            runat="server" 
            onselected="SqlDataSourceSelectedJobs_Selected" 
            onselecting="SqlDataSource_Selecting"
            ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
            ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" 
            EnableViewState="False" 
            SelectCommand="PCKG_GUI.SP_GUI_MBATCH_SEL_JBS" 
            SelectCommandType="StoredProcedure" >
                        <SelectParameters>
                            <asp:ControlParameter Name="ENG_ID_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255" ControlID="dropdown_PDCEngine" PropertyName="SelectedValue" />
                            <asp:Parameter Name="USER_IN" Direction="Input" DefaultValue="DBG_USER" DbType="String" Size="255"/>
                            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_STREAM_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_JOB_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_JOB_TYPE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_TABLE_NAME_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_PHASE_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:SessionParameter Name="FLT_JOB_CATEGORY_IN" Direction="Input" DefaultValue=" " DbType="String" Size="255"/>
                            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                            <asp:SessionParameter Name="VALUES_OUT" Direction="Output" DefaultValue="" DbType="String" Size="255"/>
                        </SelectParameters>
                    </asp:SqlDataSource>
                    <div class="breaker_portlet">
                        &nbsp;</div>
                </td>
            </tr>
        </table>
        <div class="breaker_portlet">
            &nbsp;</div>
        <asp:Panel ID="p_Manual_Buttons" runat="server" EnableViewState="True" Visible="False">
            <p>
            <span class="ModuleHeader">Step 3: Operate Manual Batch</span>
            </p> 
            <asp:LinkButton ID="LBManBatchStart" runat="server"  CommandName="COMMAND_MANBATCH_START" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton" Visible="True"><span><b class="SchedStart">Start</b></span></asp:LinkButton>
            &nbsp;
            <asp:LinkButton ID="LBManBatchCancel" runat="server" CommandName="COMMAND_MANBATCH_CANCEL" CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span><b class="SchedStop">Cancel</b></span></asp:LinkButton>
            <div class="breaker_portlet">
                &nbsp;</div>
        </asp:Panel>


    </asp:Panel>
    <asp:Panel ID="p_Manual_FinishRunning" runat="server" EnableViewState="True" Visible="False"
        CssClass="PortletBoxInner">
         <p>
        <span class="ModuleHeader">Manual Batch started. Cancel?</span>
     </p>       
        <asp:LinkButton ID="LBManBatchFinishRunning" runat="server" CommandName="COMMAND_MANBATCH_CANCEL"
            CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span><b class="SchedStop">Cancel</b></span></asp:LinkButton>&nbsp;all running jobs.
        <div class="breaker_portlet">
            &nbsp;</div>
    </asp:Panel>
        <asp:Panel ID="p_Manual_CancelManBatch" runat="server" EnableViewState="True" Visible="False"
        CssClass="PortletBoxInner">
         <p>
        <span class="ModuleHeader">Manual Batch already running or has been initialized. Finish/Cancel?</span>
     </p>       
        <asp:LinkButton ID="LBCancelManBatch" runat="server" CommandName="COMMAND_MANBATCH_CANCEL"
            CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span><b class="SchedStop">Finish</b></span></asp:LinkButton>
        <div class="breaker_portlet">
            &nbsp;</div>
    </asp:Panel>
    
    <asp:Panel ID="p_Manual_Clear" runat="server" EnableViewState="True" Visible="False"
        CssClass="PortletBoxInner">
         <p>
        <span class="ModuleHeader">Manual Batch already finished. Clear?</span>
     </p>       
        <asp:LinkButton ID="LBCancelCancelInit" runat="server" CommandName="COMMAND_MANBATCH_CANCEL"
            CommandArgument="true" OnCommand="BPDCCommandPressed" CssClass="PDCButton"><span><b class="SchedStop">Clear</b></span></asp:LinkButton>
        <div class="breaker_portlet">
            &nbsp;</div>
    </asp:Panel>
</asp:Content>
